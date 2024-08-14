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
        button.backgroundColor = UIColor(red: 92/255, green: 223/255, blue: 231/255, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didselfcareAddButton), for: .touchUpInside)
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
    }
    
    private func setupButtonConstraints() {
        NSLayoutConstraint.activate([
            selfcareAddButton.centerXAnchor.constraint(equalTo: view.centerXAnchor), // 수평 중앙 정렬
            selfcareAddButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10), // 셀 하단에 위치
            selfcareAddButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1), // 높이 비율 조정
            selfcareAddButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8) // 너비 비율 조정
        ])
    }
    // AddmanagementViewController navigation 연결
    @objc private func didselfcareAddButton() {
        let addManagementViewModel = AddManagementViewModel(categoryId: "default")
        let addManagementVC = AddManagementViewController(viewModel: addManagementViewModel)
    
        navigationController?.pushViewController(addManagementVC, animated: true)
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
        // Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (action, view, completionHandler) in
            self.viewModel?.checklistItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red
        deleteAction.image = UIImage(systemName: "trash") // SF Symbol for delete action
        
        // Alarm action
        let alarmAction = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
            print("Alarm tapped for item at index \(indexPath.row)")
            completionHandler(true)
        }
        alarmAction.backgroundColor = .gray
        alarmAction.image = UIImage(systemName: "bell.slash") // SF Symbol for alarm action
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, alarmAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
}
