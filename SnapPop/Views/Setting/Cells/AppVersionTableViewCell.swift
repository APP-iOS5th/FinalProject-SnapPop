//
//  AppVersionTableViewCell.swift
//  SnapPop
//
//  Created by 이인호 on 9/4/24.
//

import UIKit

class AppVersionTableViewCell: UITableViewCell {
    static let identifier = "appVersion"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "버전 정보"
        return label
    }()
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.text = "1.0"
        label.textColor = .gray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(versionLabel)
        selectionStyle = .none
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            versionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            versionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
