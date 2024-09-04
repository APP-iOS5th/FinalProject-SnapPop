//
//  ManagementTableViewCell.swift
//  SnapPop
//
//  Created by 정종원 on 8/30/24.
//

import UIKit

class ManagementTableViewCell: UITableViewCell {

    // MARK: - Properties
    static let identifier = "ManagementTableViewCell"
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    private func setupLayout() {
        contentView.backgroundColor = .customBackgroundColor
        contentView.addSubviews([
            titleLabel,
            timeLabel
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(title: String, time: String) {
        titleLabel.text = title
        timeLabel.text = time
    }
    
}
