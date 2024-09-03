//
//  CategoryEmptyViewController.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/30/24.
//

import UIKit

class CategoryEmptyViewController: UIViewController {
    var viewModel: CustomNavigationBarViewModelProtocol // ViewModel 프로퍼티 추가
    
    private let categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "CategoryEmptyBG") // 일러스트 이미지 이름
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        let text = """
        카테고리를 추가하고,
        스냅 사진으로 진행 상황을 쉽게 확인해보세요!
        """
        
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4 // 줄 간격 설정
        paragraphStyle.alignment = .center // 가운데 정렬

        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        
        label.attributedText = attributedString
        label.textColor = .dynamicTextColor
        label.textAlignment = .center
        label.numberOfLines = 0 // 여러 줄을 표시하도록 설정
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("카테고리 추가하기", for: .normal)
        button.backgroundColor = UIColor.customButtonColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: CustomNavigationBarViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside) // 버튼 액션 추가
    }

    private func setupViews() {
        view.backgroundColor = UIColor.customBackgroundColor
        view.addSubview(categoryImageView)
        view.addSubview(messageLabel)
        view.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            categoryImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.bounds.height * 0.2), // 아래로 내리기 위해 여백 증가
            categoryImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            categoryImageView.heightAnchor.constraint(equalTo: categoryImageView.widthAnchor), // 정사각형 유지
            
            messageLabel.topAnchor.constraint(equalTo: categoryImageView.bottomAnchor, constant: view.bounds.height * 0.1), // 아래로 내리기 위해 여백 증가
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.05), // 상대값으로 변경
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.bounds.width * 0.05), // 상대값으로 변경
            
            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: view.bounds.height * 0.1), // 아래로 내리기 위해 여백 증가
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            actionButton.heightAnchor.constraint(equalToConstant: 50),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])
    }
    
   @objc private func handleCategoryEmptycheck() {
        // 카테고리 상태가 변경되었을 때의 처리
        print("CategoryEmptyViewController: Category state changed")
        // UI 업데이트 로직 추가 (예: 뷰를 닫거나 다른 작업 수행)
        //dismiss(animated: true, completion: nil)
    }

    @objc private func actionButtonTapped() {
        let sheetViewController = CategorySettingsViewController(viewModel: self.viewModel) // 기존 ViewModel 인스턴스 사용
        // 시트 프레젠테이션 설정
        if let sheet = sheetViewController.sheetPresentationController {
            sheet.detents = [.medium()] // 시트 크기 설정
            sheet.prefersGrabberVisible = true // 그랩바 표시
        }
        self.present(sheetViewController, animated: true, completion: nil) // 뷰 컨트롤러 표시
    }
}
