//
//  SnapComparisonViewController.swift
//  SnapPop
//
//  Created by 정종원 on 8/8/24.
//

import UIKit

class SnapComparisonViewController: UIViewController {
    
    // MARK: - Properties
    /// 스냅 비교 뷰 모델
    private var viewModel: SnapComparisonViewModelProtocol
    
    /// 스냅 사진 선택 메뉴
    private var snapPhotoMenuItems: [UIAction] {
        return viewModel.snapPhotoMenuItems
    }
    
    /// 스냅 주기 선택 메뉴
    private var snapPeriodMenuItems: [UIAction] {
        return viewModel.snapPeriodMenuItems
    }
    
    // MARK: - UIComponents
    /// 스냅 사진 선택 버튼
    private lazy var selectSnapPhotoButton: UIButton = {
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.title = "전체"
        buttonConfig.image = UIImage(systemName: "photo")
        buttonConfig.imagePadding = 3
        buttonConfig.baseBackgroundColor = UIColor.customButtonColor
        buttonConfig.baseForegroundColor = .black
        buttonConfig.background.cornerRadius = 8
        buttonConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 15)
            return outgoing
        }
        buttonConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        let button = UIButton(configuration: buttonConfig)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// 스냅 주기 선택 버튼
    private lazy var selectSnapPeriodButton: UIButton = {
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.title = "전체"
        buttonConfig.image = UIImage(systemName: "slider.vertical.3")
        buttonConfig.imagePadding = 3
        buttonConfig.baseBackgroundColor = UIColor.customButtonColor
        buttonConfig.baseForegroundColor = .black
        buttonConfig.background.cornerRadius = 8
        buttonConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 15)
            return outgoing
        }
        buttonConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        let button = UIButton(configuration: buttonConfig)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// 기준 스냅 선택 버튼
    private lazy var selectSnapDateButton: UIButton = {
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.title = "날짜 선택"
        buttonConfig.image = UIImage(systemName: "calendar")
        buttonConfig.imagePadding = 3
        buttonConfig.baseBackgroundColor = UIColor.customButtonColor
        buttonConfig.baseForegroundColor = .black
        buttonConfig.background.cornerRadius = 8
        buttonConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 15)
            return outgoing
        }
        buttonConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        let button = UIButton(configuration: buttonConfig)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// 버튼들의 스택뷰
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [selectSnapDateButton, selectSnapPhotoButton, selectSnapPeriodButton])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .top
        stackView.distribution = .fillProportionally
        stackView.backgroundColor = .dynamicBackgroundInsideColor
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    /// 스택뷰를 넣을 스크롤뷰
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .customBackgroundColor
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    /// 스냅 콜렉션 뷰
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SnapComparisonCollectionViewCell.self, forCellWithReuseIdentifier: SnapComparisonCollectionViewCell.identifier)
        collectionView.backgroundColor = .dynamicBackgroundInsideColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    /// 스냅, 카테고리 유무 레이블
    private lazy var snapAndCategoryCheckLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializers
    init(viewModel: SnapComparisonViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .categoryDidChange, object: nil)
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        
        self.view.backgroundColor = .customBackgroundColor
        
        if let currentCategoryId = UserDefaults.standard.string(forKey: "currentCategoryId") {
            viewModel.loadSanpstoFireStore(to: currentCategoryId)
        } else {
            viewModel.snapDateMenuItems = []
            viewModel.categoryisEmpty?()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(categoryDidChange(_:)), name: .categoryDidChange, object: nil)
        
        setupBindings()
        setupLayout()
        setupMenu()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let currentCategoryId = UserDefaults.standard.string(forKey: "currentCategoryId") {
            viewModel.loadSanpstoFireStore(to: currentCategoryId)
        } else {
            viewModel.snapData = [] // 원본 스냅 초기화
            viewModel.snapDateMenuItems = [] // 메뉴 아이템 초기화
            viewModel.categoryisEmpty?()
        }
        DispatchQueue.main.async {
            self.setupMenu()
        }
        reloadCollectionView()
    }
    
    // MARK: - Methods
    func setupLayout() {
        
        scrollView.addSubview(buttonStackView)
        
        view.addSubviews([
            scrollView,
            collectionView,
            snapAndCategoryCheckLabel
        ])
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            scrollView.heightAnchor.constraint(equalToConstant: 44),

            buttonStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 50),
            buttonStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -10),
            buttonStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            collectionView.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            snapAndCategoryCheckLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            snapAndCategoryCheckLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
    }
    
    func setupMenu() {
        print("[스냅 비교] setupMenu 호출")
        let selectSnapMenu = UIMenu(title: "스냅 비교 사진 선택",
                                    children: snapPhotoMenuItems)
        selectSnapPhotoButton.menu = selectSnapMenu
        selectSnapPhotoButton.showsMenuAsPrimaryAction = true
        
        let selectPeriodMenu = UIMenu(title: "스냅 비교 주기",
                                      children: snapPeriodMenuItems)
        selectSnapPeriodButton.menu = selectPeriodMenu
        selectSnapPeriodButton.showsMenuAsPrimaryAction = true
        
        let selectDateMenu = UIMenu(title: "날짜 선택", children: viewModel.snapDateMenuItems.map { action in
            UIAction(title: action.title, handler: { [weak self] _ in
                if let date = self?.titleToDateString(action.title) {
                    self?.viewModel.changeSnapDate(date: date) {
                        self?.reloadCollectionView()
                    }
                }
            })
        })
        selectSnapDateButton.menu = selectDateMenu
        selectSnapDateButton.showsMenuAsPrimaryAction = true
    }
    
    private func titleToDateString(_ title: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 d일"
        return formatter.date(from: title)
    }
    
    func setupBindings() {
        viewModel.reloadCollectionView = { [weak self] in
            self?.reloadCollectionView()
        }
        viewModel.updateSnapPhotoButtonTitle = { [weak self] title in
            self?.selectSnapPhotoButton.setTitle(title, for: .normal)
        }
        viewModel.updateSnapPeriodButtonTitle = { [weak self] title in
            self?.selectSnapPeriodButton.setTitle(title, for: .normal)
        }
        viewModel.updateSnapDateButtonTitle = { [weak self] title in
            self?.selectSnapDateButton.setTitle(title, for: .normal)
        }
        viewModel.categoryisEmpty = {
            self.collectionView.isHidden = true
            self.snapAndCategoryCheckLabel.isHidden = false
            self.snapAndCategoryCheckLabel.text = "카테고리를 추가하여 사진을 비교해 보세요!"
        }
        viewModel.snapisEmpty = {
            self.collectionView.isHidden = true
            self.snapAndCategoryCheckLabel.isHidden = false
            self.snapAndCategoryCheckLabel.text = "스냅을 추가해 비교해 보세요!"
        }
        viewModel.showSnapCollectionView = {
            self.collectionView.isHidden = false
            DispatchQueue.main.async {
                self.setupMenu()
                self.collectionView.reloadData()
            }
            self.snapAndCategoryCheckLabel.isHidden = true
            self.snapAndCategoryCheckLabel.text = ""
        }
        viewModel.updateMenu = { [weak self] in
            DispatchQueue.main.async {
                self?.setupMenu()
            }
        }
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    @objc private func categoryDidChange(_ notification: Notification) {
        if let userInfo = notification.userInfo, let categoryId = userInfo["categoryId"] as? String {
            print("[스냅 비교뷰] 카테고리가 변경되었습니다: \(categoryId)")
            viewModel.categoryDidChange(to: categoryId)
        } else {
            print("카테고리가 없습니다.")
            viewModel.categoryDidChange(to: nil)
        }
    }
}

// MARK: - UICollectionViewDelegate, DataSource Methods
extension SnapComparisonViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfRows(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SnapComparisonCollectionViewCell.identifier, for: indexPath) as? SnapComparisonCollectionViewCell else {
            return UICollectionViewCell()
        }
                
        let cellViewModel = SnapComparisonCellViewModel()
        let data = viewModel.item(at: indexPath)
        let filteredSnapData = viewModel.filteredSnapData
        
        cell.configure(with: cellViewModel, data: data, filteredData: filteredSnapData, sectionIndex: indexPath.section)
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout Methods
extension SnapComparisonViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 20
        return CGSize(width: width, height: 250)
    }
    
}
