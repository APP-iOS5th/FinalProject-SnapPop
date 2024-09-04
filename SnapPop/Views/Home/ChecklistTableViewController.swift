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
        button.setTitle("새로운 관리 등록하기 +", for: .normal)
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
        view.backgroundColor = .dynamicBackgroundInsideColor
        tableView.layer.cornerRadius = 20
        tableView.layer.masksToBounds = true
        
        tableView.register(ChecklistTableViewCell.self, forCellReuseIdentifier: "ChecklistCell")
        tableView.dataSource = self
        tableView.delegate = self
        let buttonHeight: CGFloat = 50 // 버튼의 높이
        let bottomPadding: CGFloat = 20 // 추가 여백
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: buttonHeight + bottomPadding, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        
        // Combine을 사용하여 checklistItems가 변경될 때마다 테이블 뷰 업데이트
        viewModel?.$filteredItems
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        // 데이터 가져오기
        loadData()
    }
    
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
            addManagementVC.hidesBottomBarWhenPushed = true // 탭바 숨기기
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
        // filteredItems를 기준으로 테이블 뷰 셀 수 결정
        return viewModel?.filteredItems.isEmpty ?? true ? 1 : viewModel?.filteredItems.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else { return UITableViewCell() }
        // 모든 관리 항목이 없거나 현재 날짜에 관리 항목이 없는 경우
        if viewModel.checklistItems.isEmpty || viewModel.filteredItems.isEmpty {
            // 관리 항목이 없을 때의 셀 반환
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            let messageLabel = UILabel()
            let message = "오늘은 관리할 항목이 없어요\n여유로운 하루 보내세요"

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4

            let attributedString = NSAttributedString(string: message, attributes: [
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.gray
            ])

            messageLabel.attributedText = attributedString
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
            cell.backgroundColor = .dynamicBackgroundInsideColor
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistCell", for: indexPath) as! ChecklistTableViewCell
            let item = viewModel.filteredItems[indexPath.row]
            
            // 선택된 날짜 전달
            cell.configure(with: item, for: viewModel.selectedDate)
            cell.backgroundColor = .dynamicBackgroundInsideColor
            // 체크박스 토글 이벤트 핸들링
            cell.onCheckBoxToggle = { [weak self] managementId, isCompleted in
                self?.handleCheckBoxToggle(managementId: managementId, isCompleted: isCompleted)
            }
            return cell
        }
    }
    
    // 높이 설정
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 관리 항목이 없거나, 현재 선택된 날짜에 관리 항목이 없는 경우
        if viewModel?.checklistItems.isEmpty ?? true || viewModel?.filteredItems.isEmpty ?? true {
            return tableView.frame.height - tableView.contentInset.top - tableView.contentInset.bottom - selfcareAddButton.frame.height - 20
        }
        return UITableView.automaticDimension
    }
    
    private func handleCheckBoxToggle(managementId: String, isCompleted: Bool) {
        guard let viewModel = viewModel else { return }
        
        // 선택된 항목의 관리 아이템 가져오기
        guard let selectedManagementIndex = viewModel.checklistItems.firstIndex(where: { $0.id == managementId }) else { return }
        
        // 관리 항목이 선택된 날짜를 가져오기
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = viewModel.selectedDate
        let selectedDateString = dateFormatter.string(from: selectedDate)
        
        // 완료 상태 업데이트
        managementService.updateCompletion(categoryId: viewModel.selectedCategoryId ?? "default", managementId: managementId, date: selectedDate, isCompleted: isCompleted) { result in
            switch result {
            case .success():
                print("Completion status updated successfully")
                
                // 완료 상태 업데이트 후 ViewModel에서 필터링 다시 적용
                if isCompleted {
                    viewModel.checklistItems[selectedManagementIndex].completions[selectedDateString] = 1
                } else {
                    viewModel.checklistItems[selectedManagementIndex].completions[selectedDateString] = 0
                }
                
                viewModel.filterManagements(for: viewModel.selectedDate) // 필터링 재적용
                self.tableView.reloadData()
            case .failure(let error):
                print("Failed to update completion status: \(error.localizedDescription)")
                self.showAlert(title: "업데이트 실패", message: "완료 상태를 업데이트할 수 없습니다. 다시 시도해 주세요.")
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel, !viewModel.filteredItems.isEmpty, indexPath.row < viewModel.filteredItems.count else {
            return
        }

        let itemToEdit = viewModel.filteredItems[indexPath.row]
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

        addManagementVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(addManagementVC, animated: true)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let viewModel = viewModel, !viewModel.filteredItems.isEmpty, indexPath.row < viewModel.filteredItems.count else {
            return nil
        }
        
        let itemToDelete = viewModel.filteredItems[indexPath.row]
        
        // 삭제 액션 정의
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (action, view, completionHandler) in
            guard let self = self else {
                completionHandler(false)
                return
            }
            
            let alertController = UIAlertController(title: "관리 항목 삭제", message: "삭제할 항목을 선택하세요.", preferredStyle: .alert)

            // 모든 관리 항목 삭제
            let deleteAllAction = UIAlertAction(title: "모든 항목 삭제", style: .destructive) { _ in
                self.deleteManagement(item: itemToDelete, deleteAll: true)
                completionHandler(true)
            }

            // 오늘 이후 관리 항목만 삭제
            let deleteFutureAction = UIAlertAction(title: "오늘 이후 항목만 삭제", style: .default) { _ in
                self.deleteManagement(item: itemToDelete, deleteAll: false)
                completionHandler(true)
            }

            // 오늘 이후 항목만 삭제
            deleteFutureAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")

            // 취소 버튼
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
                completionHandler(false)
            }

            alertController.addAction(deleteAllAction)
            alertController.addAction(deleteFutureAction)
            alertController.addAction(cancelAction)

            self.present(alertController, animated: true, completion: nil)

        }
        deleteAction.backgroundColor = UIColor.red
        deleteAction.image = UIImage(systemName: "trash")
        
        // 삭제 액션만 추가
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    private func deleteManagement(item: Management, deleteAll: Bool) {
        guard let viewModel = viewModel else { return }

        if deleteAll {
            viewModel.deleteManagement(userId: AuthViewModel.shared.currentUser?.uid ?? "", categoryId: viewModel.selectedCategoryId ?? "default", managementId: item.id ?? "") { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        viewModel.checklistItems.removeAll { $0.id == item.id }
                        viewModel.filterManagements(for: viewModel.selectedDate)
                        self.tableView.reloadData()
                    case .failure(let error):
                        self.showAlert(title: "삭제 실패", message: "관리 항목을 삭제할 수 없습니다. 다시 시도해 주세요.")
                        print("Failed to delete management: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            managementService.deleteFutureCompletions(categoryId: viewModel.selectedCategoryId ?? "default", managementId: item.id ?? "", from: viewModel.selectedDate) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        if let index = viewModel.checklistItems.firstIndex(where: { $0.id == item.id }) {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            // 삭제된 날짜에 따라서 completions도 삭제되게
                            viewModel.checklistItems[index].completions = viewModel.checklistItems[index].completions.filter { key, _ in
                                return key < dateFormatter.string(from: self.viewModel!.selectedDate)
                            }
                        }
                        viewModel.filterManagements(for: viewModel.selectedDate)
                        self.tableView.reloadData()
                    case .failure(let error):
                        self.showAlert(title: "업데이트 실패", message: "미래 항목을 삭제할 수 없습니다. 다시 시도해 주세요.")
                        print("Failed to delete future completions: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    // 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
