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
        buttonConfig.imagePadding = 5
        buttonConfig.baseBackgroundColor = UIColor.customButtonColor
        buttonConfig.baseForegroundColor = .black
        buttonConfig.background.cornerRadius = 8
        let button = UIButton(configuration: buttonConfig)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// 스냅 주기 선택 버튼
    private lazy var selectSnapPeriodButton: UIButton = {
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.title = "전체"
        buttonConfig.image = UIImage(systemName: "slider.vertical.3")
        buttonConfig.imagePadding = 5
        buttonConfig.baseBackgroundColor = UIColor.customButtonColor
        buttonConfig.baseForegroundColor = .black
        buttonConfig.background.cornerRadius = 8
        let button = UIButton(configuration: buttonConfig)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Initializers
    init(viewModel: SnapComparisonViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        
        self.view.backgroundColor = .white
        
        setupBindings()
        setupLayout()
        setupMenu()
        
    }
    
    // MARK: - Methods
    func setupLayout() {
        
        view.addSubviews([
            selectSnapPhotoButton,
            selectSnapPeriodButton,
            collectionView
        ])
        
        NSLayoutConstraint.activate([
            selectSnapPeriodButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            selectSnapPeriodButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            selectSnapPhotoButton.topAnchor.constraint(equalTo: selectSnapPeriodButton.topAnchor),
            selectSnapPhotoButton.trailingAnchor.constraint(equalTo: selectSnapPeriodButton.leadingAnchor, constant: -10),
            
            collectionView.topAnchor.constraint(equalTo: selectSnapPhotoButton.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    
    func setupMenu() {
        
        let selectSnapMenu = UIMenu(title: "스냅 비교 사진 선택",
                                    children: snapPhotoMenuItems)
        selectSnapPhotoButton.menu = selectSnapMenu
        selectSnapPhotoButton.showsMenuAsPrimaryAction = true
        
        let selectPeriodMenu = UIMenu(title: "스냅 비교 주기",
                                      children: snapPeriodMenuItems)
        selectSnapPeriodButton.menu = selectPeriodMenu
        selectSnapPeriodButton.showsMenuAsPrimaryAction = true
        
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
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
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
