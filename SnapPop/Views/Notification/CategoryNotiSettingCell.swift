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
    
    var notificationButtonTapped: (() -> Void)?
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var notificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapNotificationButton), for: .touchUpInside)
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
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            notificationButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            notificationButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with category: Category) {
        titleLabel.text = category.title
        isNotificationEnabled = category.alertStatus
    }
    
    @objc private func didTapNotificationButton() {
        isNotificationEnabled.toggle()
        notificationButtonTapped?()
        // 해당 카테고리의 알람 toggle -> 파이어베이스 연동
    }
    
    private func updateNotificationButtonImage() {
        if isNotificationEnabled {
            notificationButton.setImage(UIImage(systemName: "bell.fill"), for: .normal)
            notificationButton.tintColor = .customMainColor
        } else {
            notificationButton.setImage(UIImage(systemName: "bell.slash.fill"), for: .normal)
            notificationButton.tintColor = .gray
        }
    }

}
