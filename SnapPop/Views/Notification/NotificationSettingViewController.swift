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
            return 2 // 추천 알림, 관리 알림
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
            
            if indexPath.row == 0 {
                cell.selectionStyle = .none
                cell.recomendCellConfigure(title: "추천 알림", isOn: true)
            } else {
                
                let menuItems: [UIAction] = [
                    UIAction(title: "5분 전", handler: { action in
                        print("5분 전 선택됨")
                    }),
                    UIAction(title: "10분 전", handler: { action in
                        print("10분 전 선택됨")
                    }),
                    UIAction(title: "30분 전", handler: { action in
                        print("30분 전 선택됨")
                    })
                ]
                cell.selectionStyle = .none
                cell.managementCellConfigure(title: "관리 알림", menuItems: menuItems)
            }
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryNotiSettingCell.identifier, for: indexPath) as? CategoryNotiSettingCell else {
                return UITableViewCell()
            }
            let category = viewModel.categories[indexPath.row]
            cell.configure(with: category)
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
