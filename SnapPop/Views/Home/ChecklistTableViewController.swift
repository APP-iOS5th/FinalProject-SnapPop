//
//  ChecklistTableViewController.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/13/24.
//

import UIKit
import Combine

class ChecklistTableViewController: UITableViewController {

    var viewModel: HomeViewModel?
    private var cancellables = Set<AnyCancellable>() // Combine 구독을 저장할 Set
    
    // 관리 항목 추가 버튼
    private let selfcareAddButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("새로운 관리 추가하기 +", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.customButtonColor
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didSelfcareAddButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(selfcareAddButton)
        setupButtonConstraints()
        
        tableView.layer.cornerRadius = 20
        tableView.layer.masksToBounds = true
        
        tableView.register(ChecklistTableViewCell.self, forCellReuseIdentifier: "ChecklistCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        // 데이터 가져오기
        if let categoryId = viewModel?.selectedCategoryId {
            viewModel?.fetchManagements(categoryId: categoryId)
        }
        
        // Combine을 사용하여 checklistItems가 변경될 때마다 테이블 뷰 업데이트
        viewModel?.$checklistItems
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setupButtonConstraints() {
        // selfcareAddButton 버튼의 제약 조건 설정
        NSLayoutConstraint.activate([
            selfcareAddButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selfcareAddButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            selfcareAddButton.heightAnchor.constraint(equalToConstant: 50),
            selfcareAddButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    // 관리 항목 추가 버튼 클릭 시 동작
    @objc private func didSelfcareAddButton() {
        let addManagementViewModel = AddManagementViewModel(categoryId: viewModel?.selectedCategoryId ?? "default")
        let addManagementVC = AddManagementViewController(viewModel: addManagementViewModel)
        addManagementVC.homeViewModel = viewModel

        // 새로운 항목이 추가되면 뷰모델에 추가
        addManagementVC.onSave = { [weak self] newManagement in
            guard let self = self, let viewModel = self.viewModel else { return }
            viewModel.addManagement(newManagement)
        }

        if let parentVC = self.view.parentViewController(), !(parentVC.navigationController?.viewControllers.contains(addManagementVC) ?? false) {
            parentVC.navigationController?.pushViewController(addManagementVC, animated: true)
        } else {
            print("Parent ViewController를 찾을 수 없거나, 이미 추가되었습니다.")
        }
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.checklistItems.count ?? 0 // checklistItems 배열의 개수 반환
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistCell", for: indexPath) as! ChecklistTableViewCell
        if let item = viewModel?.checklistItems[indexPath.row] {
            cell.configure(with: item) // 셀을 item 데이터로 구성
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 삭제 액션 정의
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (action, view, completionHandler) in
            guard let self = self, let viewModel = self.viewModel else {
                completionHandler(false)
                return
            }
            
            let itemToDelete = viewModel.checklistItems[indexPath.row]
            
            // Firebase에서 항목 삭제
            viewModel.deleteManagement(categoryId: viewModel.selectedCategoryId ?? "default", managementId: itemToDelete.id ?? "") { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        // 삭제가 성공한 경우 UI 업데이트
                        viewModel.checklistItems.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        completionHandler(true)
                    case .failure(let error):
                        // 삭제가 실패한 경우 사용자에게 알림
                        print("Failed to delete management: \(error.localizedDescription)")
                        let alert = UIAlertController(title: "삭제 실패", message: "관리 항목을 삭제할 수 없습니다. 다시 시도해 주세요.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default))
                        self.present(alert, animated: true)
                        completionHandler(false)
                    }
                }
            }
        }
        deleteAction.backgroundColor = .red
        deleteAction.image = UIImage(systemName: "trash")
        
        // 편집 액션 정의
        let editAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in
            guard let self = self, let viewModel = self.viewModel else {
                completionHandler(false)
                return
            }
            
            let itemToEdit = viewModel.checklistItems[indexPath.row]
            let addManagementViewModel = AddManagementViewModel(categoryId: viewModel.selectedCategoryId ?? "default", management: itemToEdit)
            let addManagementVC = AddManagementViewController(viewModel: addManagementViewModel)
            addManagementVC.homeViewModel = viewModel

            // 편집이 끝난 후 업데이트하기 위한 클로저
            addManagementVC.onSave = { [weak self] updatedManagement in
                guard let self = self else { return }
                
                // Firebase에서 관리 항목 업데이트
                viewModel.updateManagement(categoryId: viewModel.selectedCategoryId ?? "default", managementId: updatedManagement.id ?? "", updatedManagement: updatedManagement) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success():
                            // 기존 항목을 업데이트하고 새로운 항목을 추가하지 않음
                            if let index = viewModel.checklistItems.firstIndex(where: { $0.id == updatedManagement.id }) {
                                viewModel.checklistItems[index] = updatedManagement
                                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                            }
                        case .failure(let error):
                            print("Failed to update management: \(error.localizedDescription)")
                            let alert = UIAlertController(title: "업데이트 실패", message: "관리 항목을 업데이트할 수 없습니다. 다시 시도해 주세요.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "확인", style: .default))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }

            self.navigationController?.pushViewController(addManagementVC, animated: true)
            completionHandler(true)
        }
        editAction.backgroundColor = .gray
        editAction.image = UIImage(systemName: "pencil")
        
        // 삭제 및 편집 액션을 구성에 추가
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }

    // 왼쪽으로 스와이프할 때 핀 고정 액션 추가
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let pinAction = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
            if let viewModel = self.viewModel {
                let item = viewModel.checklistItems.remove(at: indexPath.row)
                viewModel.checklistItems.insert(item, at: 0) // 선택한 항목을 리스트의 맨 앞으로 이동
                tableView.reloadData()
            }
            completionHandler(true)
        }
        pinAction.backgroundColor = .systemYellow
        pinAction.image = UIImage(systemName: "pin")
        
        let configuration = UISwipeActionsConfiguration(actions: [pinAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    // 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
