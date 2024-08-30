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
    private let managementService = ManagementService() // ManagementService 인스턴스 추가
    
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
    // 로딩 있을 때를 대비한 loading indicator (필요시)
//    private let loadingIndicator: UIActivityIndicatorView = {
//        let indicator = UIActivityIndicatorView(style: .large)
//        indicator.translatesAutoresizingMaskIntoConstraints = false
//        return indicator
//    }()

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
        loadData()

        // Combine을 사용하여 checklistItems가 변경될 때마다 테이블 뷰 업데이트
        viewModel?.$checklistItems
             .receive(on: RunLoop.main)
             .sink { [weak self] _ in
//                 self?.tableView.reloadData()
//                 self?.startLoading()
                 self?.loadData()

             }
             .store(in: &cancellables)
     }
//    // 카테고리 변경 시 로딩 indicator
//    private func startLoading() {
//        loadingIndicator.startAnimating()
//    }
//
//    private func stopLoading() {
//        loadingIndicator.stopAnimating()
//    }

    private func setupButtonConstraints() {
        NSLayoutConstraint.activate([
            selfcareAddButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selfcareAddButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            selfcareAddButton.heightAnchor.constraint(equalToConstant: 50),
            selfcareAddButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }

    private func loadData() {
        guard let viewModel = viewModel else { return }
        viewModel.fetchManagements(categoryId: viewModel.selectedCategoryId ?? "default") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.showAlert(title: "데이터 로드 실패", message: error.localizedDescription)
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    // 관리 항목 추가 버튼 클릭 시 동작
    @objc private func didSelfcareAddButton() {
        let addManagementViewModel = AddManagementViewModel(categoryId: viewModel?.selectedCategoryId ?? "default")
        let addManagementVC = AddManagementViewController(viewModel: addManagementViewModel)
        addManagementVC.homeViewModel = viewModel

        // 새로운 항목이 추가되면 뷰모델에 추가
        addManagementVC.onSave = { [weak self] newManagement in
            guard let self = self, let viewModel = self.viewModel else { return }
            
            // 중복 항목 확인 후 추가
            if !viewModel.checklistItems.contains(where: { $0.id == newManagement.id }) {
                viewModel.addManagement(newManagement)
            }
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
        // 관리 항목이 없을 경우에도 하나의 셀이 필요
        return viewModel?.checklistItems.isEmpty ?? true ? 1 : viewModel?.checklistItems.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else { return UITableViewCell() }
        
        if viewModel.checklistItems.isEmpty {
            // 관리 항목이 없을 때 메시지 셀을 반환
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            let messageLabel = UILabel()
            messageLabel.text = "새로운 관리 추가하기를 통해 관리를 시작해보세요!"
            messageLabel.textAlignment = .center
            messageLabel.textColor = .gray
            messageLabel.numberOfLines = 0
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addSubview(messageLabel)
            
            // 메시지 레이블을 셀의 중앙에 배치
            NSLayoutConstraint.activate([
                messageLabel.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                messageLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                messageLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                messageLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16)
            ])
            
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude) // 셀의 구분선 제거
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistCell", for: indexPath) as! ChecklistTableViewCell
            let item = viewModel.checklistItems[indexPath.row]
            cell.configure(with: item)
            
            // 체크박스 상태가 변경될 때 호출할 클로저 설정
            cell.onCheckBoxToggle = { [weak self] managementId, isCompleted in
                self?.handleCheckBoxToggle(managementId: managementId, isCompleted: isCompleted)
            }
            return cell
        }
    }

    // 높이 설정
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 관리 항목이 없을 때 셀의 높이를 테이블 뷰의 나머지 높이로 설정하여 가운데 배치
        if viewModel?.checklistItems.isEmpty ?? true {
            return tableView.frame.height - tableView.contentInset.top - tableView.contentInset.bottom - selfcareAddButton.frame.height - 20 // 추가적인 마진 값
        }
        return UITableView.automaticDimension
    }
    
    private func handleCheckBoxToggle(managementId: String, isCompleted: Bool) {
        guard let viewModel = viewModel else { return }
        let currentDate = Date()
        
        managementService.updateCompletion(categoryId: viewModel.selectedCategoryId ?? "default", managementId: managementId, date: currentDate, isCompleted: isCompleted) { result in
            switch result {
            case .success():
                print("Completion status updated successfully")
            case .failure(let error):
                print("Failed to update completion status: \(error.localizedDescription)")
                self.showAlert(title: "업데이트 실패", message: "완료 상태를 업데이트할 수 없습니다. 다시 시도해 주세요.")
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 관리 항목이 없을 때는 스와이프 동작을 비활성화
        guard let viewModel = viewModel, !viewModel.checklistItems.isEmpty else {
            return nil
        }
        // 삭제 액션 정의
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (action, view, completionHandler) in
            guard let self = self, let viewModel = self.viewModel else {
                completionHandler(false)
                return
            }
            
            let itemToDelete = viewModel.checklistItems[indexPath.row]
            
            // Firebase에서 항목 삭제
            viewModel.deleteManagement(userId: AuthViewModel.shared.currentUser?.uid ?? "", categoryId: viewModel.selectedCategoryId ?? "default", managementId: itemToDelete.id ?? "") { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        // 삭제가 성공한 경우 UI 업데이트
                        viewModel.checklistItems.remove(at: indexPath.row)
                        
                        if viewModel.checklistItems.isEmpty {
                            // 모든 항목이 삭제된 경우 전체 섹션을 다시 로드하여 빈 상태를 보여줍니다.
                            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                        } else {
                            // 항목이 남아 있는 경우 해당 행만 삭제합니다.
                            tableView.deleteRows(at: [indexPath], with: .automatic)
                        }
                        
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
            addManagementViewModel.edit = true // 편집 모드 설정
            let addManagementVC = AddManagementViewController(viewModel: addManagementViewModel)
            addManagementVC.homeViewModel = viewModel

            addManagementVC.onSave = { [weak self] updatedManagement in
                guard let self = self else { return }
                
                viewModel.updateManagement(categoryId: viewModel.selectedCategoryId ?? "default", managementId: updatedManagement.id ?? "", updatedManagement: updatedManagement) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success():
                            self.tableView.reloadData()
                            addManagementViewModel.edit = false // 업데이트 후 edit를 다시 false로 설정
                        case .failure(let error):
                            self.showAlert(title: "업데이트 실패", message: "관리 항목을 업데이트할 수 없습니다. 다시 시도해 주세요.")
                            print("Failed to update management: \(error.localizedDescription)")
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
        guard let viewModel = viewModel, !viewModel.checklistItems.isEmpty else {
            return nil
        }
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
