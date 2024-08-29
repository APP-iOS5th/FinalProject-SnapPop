//
//  NotificationSettingViewController.swift
//  SnapPop
//
//  Created by 정종원 on 8/29/24.
//

import UIKit

class NotificationSettingViewController: UIViewController {
    // MARK: - Properties
    var viewModel: NotificationSettingViewModelProtocol
    // MARK: - UI Components
    /// 테이블뷰
    private lazy var notificationTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NotificationSettingCell.self, forCellReuseIdentifier: NotificationSettingCell.identifier)
        tableView.register(CategoryNotiSettingCell.self, forCellReuseIdentifier: CategoryNotiSettingCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Initializers
    init(viewModel: NotificationSettingViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.customBackground
        viewModel.loadCategories {
            DispatchQueue.main.async {
                self.notificationTableView.reloadData()
            }
        }
        setupLayout()
    }
    
    // MARK: - Methods
    private func setupLayout() {
        view.addSubview(notificationTableView)
        NSLayoutConstraint.activate([
            notificationTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            notificationTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            notificationTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            notificationTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    // MARK: - Actions
}

// MARK: - UITableViewDelegate, DataSource Methods
extension NotificationSettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // 알림 섹션과 카테고리 알림 설정 섹션
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1 // 추천 알림
        case 1:
            return viewModel.categories.count // 카테고리의 수
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationSettingCell.identifier, for: indexPath) as? NotificationSettingCell else {
                return UITableViewCell()
            }
            
            cell.selectionStyle = .none
            cell.configure(title: "추천 알림", isOn: true)
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryNotiSettingCell.identifier, for: indexPath) as? CategoryNotiSettingCell else {
                return UITableViewCell()
            }
            let category = viewModel.categories[indexPath.row]
            cell.configure(with: category)
            cell.notificationButtonTapped = { [weak self] in
                guard let self = self else { return }
                let index = indexPath.row
                self.viewModel.categories[index].alertStatus.toggle()
                
               
                let updatedCategory = self.viewModel.categories[index]
                guard let updatedCategoryId = updatedCategory.id else { return }
                
                // 알림 상태에 따라 버튼 이미지 변경
                let alertStatusImage = updatedCategory.alertStatus ? "bell" : "bell.slash"
                cell.notificationButton.setImage(UIImage(systemName: alertStatusImage), for: .normal)
                
                // 알림 상태에 따른 알림 삭제 or 추가
                if updatedCategory.alertStatus {
                    // 알림 ON
                    // 1. 기존 Managements의 alertStateTrue 알림 삭제
                    self.viewModel.removeAllNotifications(for: updatedCategoryId)
                    // 2. Managements의 alertStateTrue의 알림 추가
                    self.viewModel.registerAllNotifications(for: updatedCategoryId)
                } else {
                    // 알림 OFF
                    // 1. Managements의 alertStateTrue의 알림 삭제
                    self.viewModel.registerAllNotifications(for: updatedCategoryId)
                }
                // TODO: - 앱 시작시 categoris의 alertState true확인 -> Managements의 true인 관리 알림에 추가.
                // TODO: - 관리에서 카테고리 알림 상태 체크하여 알림 추가
                
                // Firebase에 업데이트 후, 테이블뷰 셀 리로드
                self.viewModel.updateCategory(categoryId: updatedCategoryId, category: updatedCategory) {
                    DispatchQueue.main.async {
                        self.notificationTableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
            cell.selectionStyle = .none
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "알림 설정"
        case 1:
            return "카테고리 알림 설정"
        default:
            return nil
        }
    }
}
