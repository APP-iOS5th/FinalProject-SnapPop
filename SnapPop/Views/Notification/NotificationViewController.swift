//
//  NotificationViewController.swift
//  SnapPop
//
//  Created by 정종원 on 8/19/24.
//

import UIKit

class NotificationViewController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: - UI Components
    private let segmentedControl: UISegmentedControl = {
        let segControl = UISegmentedControl(items: ["추천 알림", "관리 알림"])
        segControl.selectedSegmentIndex = 0
        segControl.backgroundColor = UIColor.white
        segControl.selectedSegmentTintColor = UIColor.customToggle
        segControl.translatesAutoresizingMaskIntoConstraints = false
        return segControl
    }()
    
    private let recomenendTable = {
        let table = UITableView()
        table.backgroundColor = .customBackground
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // 관리 알람은 title: 오늘 ~~ 하셨나요? subTitle: 오늘의 관리 확인하기
    private let managementTable = {
        let table = UITableView()
        table.backgroundColor = .customBackground
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .customBackground
        
        view.addSubviews([
            segmentedControl,
            recomenendTable,
            managementTable
        ])
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            segmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 10),
            segmentedControl.heightAnchor.constraint(equalToConstant: 44),
            
            recomenendTable.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            recomenendTable.leadingAnchor.constraint(equalTo: segmentedControl.leftAnchor),
            recomenendTable.trailingAnchor.constraint(equalTo: segmentedControl.rightAnchor),
            recomenendTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
        ])
    }
    
    // MARK: - Methods
    
    // MARK: - Actions

}
