//
//  CategoryNotiSettingCell.swift
//  SnapPop
//
//  Created by 정종원 on 8/29/24.
//

import UIKit

class CategoryNotiSettingCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "CategoryNotiSettingCell"
    private var isNotificationEnabled: Bool = false {
        didSet {
            updateNotificationButtonImage()
        }
    }
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var notificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(notificationButtonTapped), for: .touchUpInside)
        return button
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
        contentView.addSubviews([
            titleLabel,
            notificationButton
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            notificationButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            notificationButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with category: Category) {
        titleLabel.text = category.title
        isNotificationEnabled = category.alertStatus
    }
    
    @objc private func notificationButtonTapped() {
        isNotificationEnabled.toggle()
        // 해당 카테고리의 알람 toggle -> 파이어베이스 연동
    }
    
    private func updateNotificationButtonImage() {
        let imageName = isNotificationEnabled ? "bell.fill" : "bell.slash.fill"
        notificationButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

}
