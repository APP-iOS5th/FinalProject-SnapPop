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
            .receive(on: RunLoop.main) // UI 업데이트는 메인 스레드에서 이루어져야 합니다.
            .sink { [weak self] _ in
                self?.tableView.reloadData() // 데이터 변경 시 테이블 뷰를 리로드
            }
            .store(in: &cancellables)
    }
    
    private func setupButtonConstraints() {
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
        return viewModel?.checklistItems.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistCell", for: indexPath) as! ChecklistTableViewCell
        if let item = viewModel?.checklistItems[indexPath.row] {
            cell.configure(with: item)
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (action, view, completionHandler) in
            if let viewModel = self.viewModel {
                viewModel.checklistItems.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red
        deleteAction.image = UIImage(systemName: "trash")
        
        let editAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in
            guard let self = self, let viewModel = self.viewModel else {
                completionHandler(false)
                return
            }
            
            // 선택한 항목 가져오기
            let itemToEdit = viewModel.checklistItems[indexPath.row]
            
            // 기존 항목을 사용하여 AddManagementViewModel 초기화
            let addManagementViewModel = AddManagementViewModel(categoryId: viewModel.selectedCategoryId ?? "default")
            addManagementViewModel.management = itemToEdit
            
            // AddManagementViewController 초기화
            let addManagementVC = AddManagementViewController(viewModel: addManagementViewModel)
            addManagementVC.homeViewModel = viewModel // HomeViewModel 전달
            
            self.navigationController?.pushViewController(addManagementVC, animated: true)
            completionHandler(true)
        }
        editAction.backgroundColor = .gray
        editAction.image = UIImage(systemName: "pencil")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    // 왼쪽으로 스와이프할 때 핀 고정 액션 추가
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let pinAction = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
            if let viewModel = self.viewModel {
                let item = viewModel.checklistItems.remove(at: indexPath.row)
                viewModel.checklistItems.insert(item, at: 0)
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
