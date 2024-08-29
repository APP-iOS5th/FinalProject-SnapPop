//
//  NotificationViewController.swift
//  SnapPop
//
//  Created by 정종원 on 8/19/24.
//

import UIKit

class NotificationViewController: UIViewController {
    
    // MARK: - Properties
    var shouldHideFirstView: Bool? {
        didSet {
            guard let shouldHideFirstView = self.shouldHideFirstView else { return }
            self.recomenendTable.isHidden = shouldHideFirstView
            self.managementTable.isHidden = !self.recomenendTable.isHidden
        }
    }
    
    // MARK: - UI Components
    /// 추천 알림, 관리 알림 선택 SegmentedControl
    private lazy var segmentedControl: UISegmentedControl = {
        let segControl = UISegmentedControl(items: ["추천 알림", "관리 알림"])
        segControl.selectedSegmentIndex = 0
        segControl.backgroundColor = UIColor.customToggle
        segControl.selectedSegmentTintColor = UIColor.white
        segControl.addTarget(self, action: #selector(didChangeValue(segment:)), for: .valueChanged)
        segControl.translatesAutoresizingMaskIntoConstraints = false
        return segControl
    }()
    
    /// 추천 알림 테이블뷰
    private lazy var recomenendTable = {
        let table = UITableView()
        table.backgroundColor = .customBackground
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // 관리 알람은 title: 오늘 ~~ 하셨나요? subTitle: 오늘의 관리 확인하기
    /// 관리 알림 테이블뷰
    private lazy var managementTable = {
        let table = UITableView()
        table.backgroundColor = .customBackground
        table.isHidden = true
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .customBackground
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "알림 설정", style: .plain, target: self, action: #selector(moveToNotificationSettingView))
        
        self.segmentedControl.selectedSegmentIndex = 0
        self.didChangeValue(segment: self.segmentedControl)
        
        setupLayout() // 레이아웃 설정
    }
    
    // MARK: - Methods
    func setupLayout() {
        view.addSubviews([
            segmentedControl,
            recomenendTable,
            managementTable
        ])
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            segmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            segmentedControl.heightAnchor.constraint(equalToConstant: 44),
            
            recomenendTable.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            recomenendTable.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor),
            recomenendTable.trailingAnchor.constraint(equalTo: segmentedControl.trailingAnchor),
            recomenendTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            managementTable.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            managementTable.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor),
            managementTable.trailingAnchor.constraint(equalTo: segmentedControl.trailingAnchor),
            managementTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - Actions
    
    @objc func didChangeValue(segment: UISegmentedControl) {
        self.shouldHideFirstView = segment.selectedSegmentIndex != 0
    }
    
    @objc func moveToNotificationSettingView() {
        let notiViewModel = NotificationSettingViewModel()
        let notificationSettingView = NotificationSettingViewController(viewModel: notiViewModel)
        self.navigationController?.pushViewController(notificationSettingView, animated: true)
    }
}

// MARK: - UITableViewDelegate, DataSource Methods
extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}
