//
//  ChecklistTableViewController.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/13/24.
//

import UIKit

class ChecklistTableViewController: UITableViewController {
    
    var viewModel: HomeViewModel?
    
    // 관리 항목 추가버튼
    private let selfcareAddButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("새로운 관리 추가하기 + ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.customButtonColor
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(ChecklistTableViewController.self, action: #selector(didselfcareAddButton), for: .touchUpInside)
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
        
        // 임시 데이터 추가
        setupTestData()
    }
    
    private func setupTestData() {
        tableView.reloadData() // 데이터 변경 반영
    }
    
    private func setupButtonConstraints() {
        NSLayoutConstraint.activate([
            selfcareAddButton.centerXAnchor.constraint(equalTo: view.centerXAnchor), // 수평 중앙 정렬
            selfcareAddButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10), // 셀 하단에 위치
            selfcareAddButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1), // 높이 비율 조정
            selfcareAddButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8) // 너비 비율 조정
        ])
    }
    
    @objc private func didselfcareAddButton() {
        print("새로운 관리 추가하기 탭")
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.checklistItems.count ?? 0
    }
    
    // MARK: Configure and Return Cell for Row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistCell", for: indexPath) as! ChecklistTableViewCell
        if let item = viewModel?.checklistItems[indexPath.row] {
            cell.configure(with: item)
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 삭제 액션
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (action, view, completionHandler) in
            // viewModel에서 항목 삭제
            if let viewModel = self.viewModel {
                viewModel.checklistItems.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red
        deleteAction.image = UIImage(systemName: "trash") // 삭제 액션을 위한 SF Symbol
        
        // 알람 액션
        let alarmAction = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
            print("인덱스 \(indexPath.row)의 항목에 대해 알람 탭")
            completionHandler(true)
        }
        alarmAction.backgroundColor = .gray
        alarmAction.image = UIImage(systemName: "bell.slash") // 알람 액션을 위한 SF Symbol
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, alarmAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
}
