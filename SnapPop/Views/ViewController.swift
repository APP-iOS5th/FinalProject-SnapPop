//
//  ViewController.swift
//  SnapPop
//
//  Created by 김형준 on 8/7/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setup()
    }
    
    func setup() {
        let button = UIButton(type: .system)
        button.setTitle("뷰이동", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
    
    @objc func buttonTapped() {
        let calendarView = CalendarViewController()
        navigationController?.pushViewController(calendarView, animated: true)
    }

}
