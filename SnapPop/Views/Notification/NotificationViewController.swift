//
//  NotificationViewController.swift
//  SnapPop
//
//  Created by 정종원 on 8/19/24.
//

import UIKit

struct NotificationData: Codable {
    let categoryId: String
    let managementId: String
    let title: String
    let date: Date
}

extension Notification.Name {
    static let newNotificationReceived = Notification.Name("newNotificationReceived")
}

class NotificationViewController: UIViewController {
    
    // MARK: - Properties
    var shouldHideFirstView: Bool? {
        didSet {
            guard let shouldHideFirstView = self.shouldHideFirstView else { return }
            self.recomenendTable.isHidden = shouldHideFirstView
            self.managementTable.isHidden = !self.recomenendTable.isHidden
        }
    }
    
    var notifications: [NotificationData] = []
    
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
    private var recomenendTable = {
        let table = UITableView()
        table.backgroundColor = .customBackground
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // 관리 알람은 title: 오늘 ~~ 하셨나요? subTitle: 오늘의 관리 확인하기
    /// 관리 알림 테이블뷰
    private var managementTable = {
        let table = UITableView()
        table.backgroundColor = .customBackground
        table.register(ManagementTableViewCell.self, forCellReuseIdentifier: "ManagementTableViewCell")
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
        
//        recomenendTable.dataSource = self
//        recomenendTable.delegate = self
        managementTable.dataSource = self
        managementTable.delegate = self
            
        
        setupLayout() // 레이아웃 설정
        
        loadNotifications()
                
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewNotification), name: .newNotificationReceived, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        loadNotifications() 
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
    
    func loadNotifications() {
        guard let savedNotifications = UserDefaults.standard.array(forKey: "savedNotifications") as? [Data] else { return }
        notifications = savedNotifications.compactMap { try? JSONDecoder().decode(NotificationData.self, from: $0) }
        DispatchQueue.main.async {
            self.managementTable.reloadData()
        }
    }
    
    // MARK: - Actions
    ///  세그먼트 피커 value 변경시 action
    @objc func didChangeValue(segment: UISegmentedControl) {
        self.shouldHideFirstView = segment.selectedSegmentIndex != 0
    }
    
    @objc func moveToNotificationSettingView() {
        let notiViewModel = NotificationSettingViewModel()
        let notificationSettingView = NotificationSettingViewController(viewModel: notiViewModel)
        self.navigationController?.pushViewController(notificationSettingView, animated: true)
    }
    
    @objc func handleNewNotification() {
        print("New notification received")
        loadNotifications()
    }
}

// MARK: - UITableViewDelegate, DataSource Methods
extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == managementTable {
            notifications.count
        } else {
            1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == managementTable {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ManagementTableViewCell.identifier, for: indexPath) as? ManagementTableViewCell else {
                return UITableViewCell()
            }
            let notification = notifications[indexPath.row]
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 MM월 d일"
            let updatedDateString = formatter.string(from: notification.date)
            cell.configure(title: notification.title, time: updatedDateString)
            
            cell.selectionStyle = .none
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notifications.remove(at: indexPath.row)
            
            if var savedNotifications = UserDefaults.standard.array(forKey: "savedNotifications") as? [Data] {
                savedNotifications.remove(at: indexPath.row)
                UserDefaults.standard.set(savedNotifications, forKey: "savedNotifications")
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
