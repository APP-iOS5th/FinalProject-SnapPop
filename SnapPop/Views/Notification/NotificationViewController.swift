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
            self.recommendTable.isHidden = shouldHideFirstView
            self.managementTable.isHidden = !self.recommendTable.isHidden
        }
    }
    
    var managementNotifications: [NotificationData] = []
    var recommendNotifications: [NotificationData] = []
    
    // MARK: - UI Components
    /// 추천 알림, 관리 알림 선택 SegmentedControl
    private lazy var segmentedControl: UISegmentedControl = {
        let segControl = UISegmentedControl(items: ["추천 알림", "관리 알림"])
        segControl.selectedSegmentIndex = 0
        segControl.backgroundColor = UIColor.segmentColor
        segControl.selectedSegmentTintColor = UIColor.segmentSelectedColor
        segControl.addTarget(self, action: #selector(didChangeValue(segment:)), for: .valueChanged)
        segControl.translatesAutoresizingMaskIntoConstraints = false
        return segControl
    }()
    
    /// 추천 알림 테이블뷰
    private var recommendTable = {
        let table = UITableView()
        table.backgroundColor = .customBackgroundColor
        table.register(ManagementTableViewCell.self, forCellReuseIdentifier: "ManagementTableViewCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    /// 관리 알림 테이블뷰
    private var managementTable = {
        let table = UITableView()
        table.backgroundColor = .customBackgroundColor
        table.register(ManagementTableViewCell.self, forCellReuseIdentifier: "ManagementTableViewCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    /// 관리 알림이 없을때의 문구
    private let managementEmptyLabel: UILabel = {
        let label = UILabel()
        label.text = "관리 알림이 없습니다"
        label.textAlignment = .center
        label.textColor = .gray
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 추천 알림이 없을때의 문구
    private let recommendEmptyLabel: UILabel = {
        let label = UILabel()
        label.text = "추천 알림이 없습니다"
        label.textAlignment = .center
        label.textColor = .gray
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .customBackgroundColor
        
        // 네비게이션
        title = "알림"
        setupLeftBarButtonItem()
        setupRightBarButtonItemForNotification()

        self.segmentedControl.selectedSegmentIndex = 1
        self.didChangeValue(segment: self.segmentedControl)
        
        recommendTable.dataSource = self
        recommendTable.delegate = self
        managementTable.dataSource = self
        managementTable.delegate = self
        
        setupLayout() // 레이아웃 설정
        
        loadManagementNotifications()
        loadRecommendedNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewManagementNotification), name: .newNotificationReceived, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewRecommendNotification), name: .newRecommendNotificationReceived, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if segmentedControl.selectedSegmentIndex == 0 {
            managementEmptyLabel.isHidden = true
            loadRecommendedNotifications()
        } else {
            recommendEmptyLabel.isHidden = true
            loadManagementNotifications()
        }
        
        enableInteractivePopGesture()
    }
    
    // MARK: - Methods
    func setupLayout() {
        view.addSubviews([
            segmentedControl,
            recommendTable,
            managementTable,
            managementEmptyLabel,
            recommendEmptyLabel
            
        ])
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            segmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            segmentedControl.heightAnchor.constraint(equalToConstant: 44),
            
            recommendTable.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            recommendTable.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor),
            recommendTable.trailingAnchor.constraint(equalTo: segmentedControl.trailingAnchor),
            recommendTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            managementTable.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            managementTable.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor),
            managementTable.trailingAnchor.constraint(equalTo: segmentedControl.trailingAnchor),
            managementTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            managementEmptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            managementEmptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            recommendEmptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recommendEmptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func loadManagementNotifications() {
        guard let savedNotifications = UserDefaults.standard.array(forKey: "savedNotifications") as? [Data] else { 
            self.managementNotifications = []
            self.managementTable.isHidden = true
            self.managementEmptyLabel.isHidden = false
            return
        }
        managementNotifications = savedNotifications.compactMap { try? JSONDecoder().decode(NotificationData.self, from: $0) }
        
        // 데이터가 없는 경우 테이블뷰를 숨기고 레이블을 표시
       
        managementTable.isHidden = managementNotifications.isEmpty
        managementEmptyLabel.isHidden = !managementNotifications.isEmpty
        DispatchQueue.main.async {
            self.managementTable.reloadData()
        }
    }
    
    func loadRecommendedNotifications() {
        guard let savedNotifications = UserDefaults.standard.array(forKey: "savedRecommendedNotifications") as? [Data] else { 
            self.recommendNotifications = []
            self.recommendTable.isHidden = true
            self.recommendEmptyLabel.isHidden = false
            return
        }
        recommendNotifications = savedNotifications.compactMap { try? JSONDecoder().decode(NotificationData.self, from: $0) }
        
        // 데이터가 없는 경우 테이블뷰를 숨기고 레이블을 표시
        recommendTable.isHidden = recommendNotifications.isEmpty
        recommendEmptyLabel.isHidden = !recommendNotifications.isEmpty
        DispatchQueue.main.async {
            self.recommendTable.reloadData()
        }
    }
    
    // MARK: - Actions
    ///  세그먼트 피커 value 변경시 action
    @objc func didChangeValue(segment: UISegmentedControl) {
        self.shouldHideFirstView = segment.selectedSegmentIndex != 0
        
        if segment.selectedSegmentIndex == 0 {
            managementEmptyLabel.isHidden = true
            loadRecommendedNotifications()
        } else {
            recommendEmptyLabel.isHidden = true
            loadManagementNotifications()
        }
    }
    
    @objc func handleNewManagementNotification() {
        print("New notification received")
        loadManagementNotifications()
    }
    
    @objc func handleNewRecommendNotification() {
        print("New notification received")
        loadRecommendedNotifications()
    }
}

// MARK: - UITableViewDelegate, DataSource Methods
extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == managementTable {
            managementNotifications.count
        } else {
            recommendNotifications.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == managementTable {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ManagementTableViewCell.identifier, for: indexPath) as? ManagementTableViewCell else {
                return UITableViewCell()
            }
            let notification = managementNotifications[indexPath.row]
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 MM월 d일"
            let updatedDateString = formatter.string(from: notification.date)
            cell.configure(title: notification.title, time: updatedDateString)
//            cell.backgroundColor = .customBackgroundColor
            cell.selectionStyle = .none
            return cell
        } else if tableView == recommendTable {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ManagementTableViewCell.identifier, for: indexPath) as? ManagementTableViewCell else {
                return UITableViewCell()
            }
            guard indexPath.row < recommendNotifications.count else {
                return UITableViewCell()
            }
            
            let notification = recommendNotifications[indexPath.row]
            
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
            if tableView == managementTable {
                // 관리 알림 삭제
                managementNotifications.remove(at: indexPath.row)
                
                if var savedNotifications = UserDefaults.standard.array(forKey: "savedNotifications") as? [Data] {
                    savedNotifications.remove(at: indexPath.row)
                    UserDefaults.standard.set(savedNotifications, forKey: "savedNotifications")
                }
                
            } else if tableView == recommendTable {
                // 추천 알림 삭제
                recommendNotifications.remove(at: indexPath.row)
                
                if var savedNotifications = UserDefaults.standard.array(forKey: "savedRecommendNotifications") as? [Data] {
                    savedNotifications.remove(at: indexPath.row)
                    UserDefaults.standard.set(savedNotifications, forKey: "savedRecommendNotifications")
                }
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
