//
//  AccountInfoTableViewCell.swift
//  SnapPop
//
//  Created by 이인호 on 8/9/24.
//

import UIKit
import FirebaseAuth

class AccountInfoTableViewCell: UITableViewCell {
    static let identifier = "accountInfo"
    
    private let snsLogin = UILabel()
    private let userEmail = UILabel()
    private let socialLogo = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.addSubview(snsLogin)
        contentView.addSubview(userEmail)
        contentView.addSubview(socialLogo)
        selectionStyle = .none
        
        snsLogin.translatesAutoresizingMaskIntoConstraints = false
        userEmail.translatesAutoresizingMaskIntoConstraints = false
        socialLogo.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            snsLogin.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            snsLogin.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            userEmail.trailingAnchor.constraint(equalTo: socialLogo.leadingAnchor, constant: -8),
            userEmail.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        
            socialLogo.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            socialLogo.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with user: User) {
        snsLogin.text = "SNS 로그인"
        userEmail.text = user.email
        userEmail.font = UIFont.systemFont(ofSize: 16, weight: .light)
        userEmail.textColor = .gray
        
        guard let providerID = user.providerData.first?.providerID else { return }
        
        if providerID == "google.com" {
            socialLogo.image = UIImage(named: "google_logo")
        } else if providerID == "apple.com" {
            socialLogo.image = UIImage(named: "apple_logo")
        }
    }
}
