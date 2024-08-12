//
//  SnapComparisonViewController.swift
//  SnapPop
//
//  Created by 정종원 on 8/8/24.
//

import UIKit

// jjTODO: Color 통합하기.
// jjTODO: 폰트추가하기....?
// jjTODO: Extension으로 빼기
extension UIView {
    func addSubviews(_ views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
    }
}

class SnapComparisonViewController: UIViewController {
    
    // MARK: - Properties
    /// 스냅 비교 뷰 모델
    private let viewModel = SnapComparisonViewModel()
    
    /// 스냅 사진 선택 메뉴
    private var snapPhotoMenuItems: [UIAction] {
        
        let allSnapPhoto = UIAction(
            title: "전체",
            handler: { _ in
                self.selectSnapPhotoButton.setTitle("전체", for: .normal)
                self.viewModel.changeSnapPhotoSelection(type: "전체") {
                    self.reloadCollectionView()
                }
            })
        
        let mainSnapPhoto = UIAction(
            title: "메인 사진",
            handler: { _ in
                self.selectSnapPhotoButton.setTitle("메인 사진", for: .normal)
                self.viewModel.changeSnapPhotoSelection(type: "메인 사진") {
                    self.reloadCollectionView()
                }
            })
        
        let items = [mainSnapPhoto, allSnapPhoto]
        
        return items
    }
    
    /// 스냅 주기 선택 메뉴
    private var snapPeriodMenuItems: [UIAction] {
        
        let perWeek = UIAction(
            title: "일주일",
            handler: { _ in
                self.selectSnapPeriodButton.setTitle("일주일", for: .normal)
                self.viewModel.changeSnapPeriod(type: "일주일") {
                    self.reloadCollectionView()
                }
            })
        
        let perMonth = UIAction(
            title: "한달",
            handler: { _ in
                self.selectSnapPeriodButton.setTitle("한달", for: .normal)
                self.viewModel.changeSnapPeriod(type: "한달") {
                    self.reloadCollectionView()
                }
            })
        
        let perYear = UIAction(
            title: "일년",
            handler: { _ in
                self.selectSnapPeriodButton.setTitle("일년", for: .normal)
                self.viewModel.changeSnapPeriod(type: "일년") {
                    self.reloadCollectionView()
                }
            })
        
        let allPeriod = UIAction(
            title: "전체",
            handler: { _ in
                self.selectSnapPeriodButton.setTitle("전체", for: .normal)
                self.viewModel.changeSnapPeriod(type: "전체") {
                    self.reloadCollectionView()
                }
            })
        
        let items = [perWeek, perMonth, perYear, allPeriod]
        
        return items
    }
    
    // MARK: - UIComponents
    /// 스냅 사진 선택 버튼
    private lazy var selectSnapPhotoButton: UIButton = {
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.title = "전체"
        buttonConfig.image = UIImage(systemName: "photo")
        buttonConfig.imagePadding = 5
        buttonConfig.baseBackgroundColor = UIColor(red: 0.57, green: 0.87, blue: 0.91, alpha: 1.00)
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
        buttonConfig.baseBackgroundColor = UIColor(red: 0.57, green: 0.87, blue: 0.91, alpha: 1.00)
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
        collectionView.register(SnapComparisonCollectionViewCell.self, forCellWithReuseIdentifier: "SnapCollectionViewCell")
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        
        self.view.backgroundColor = .white
        
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
    
    func reloadCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDelegate, DataSource Methods
extension SnapComparisonViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfRows(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SnapCollectionViewCell", for: indexPath) as? SnapComparisonCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: viewModel.item(at: indexPath))
        
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

#Preview {
    SnapComparisonViewController()
}
