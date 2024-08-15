//
//  SnapComparisonSheetViewController.swift
//  SnapPop
//
//  Created by 정종원 on 8/9/24.
//

import UIKit

class SnapComparisonSheetViewController: UIViewController {
    // MARK: - Properties
    var viewModel: SnapComparisonSheetViewModelProtocol
    
    // MARK: - UIComponents
    /// 스냅 날자
    lazy var snapDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 스냅 왼쪽 화살표 버튼
    private lazy var leftArrowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapLeftArrow), for: .touchUpInside)
        return button
    }()
    
    /// 스냅 오른쪽 화살표 버튼
    private lazy var rightArrowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapRightArrow), for: .touchUpInside)
        return button
    }()
    
    /// 페이지뷰 컨트롤러
    private var pageViewController: UIPageViewController = {
        let pageVC = UIPageViewController()
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        return pageVC
    }()
    
    /// 페이지 컨트롤
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = viewModel.currentSnap.images.count
        pageControl.currentPage = viewModel.currentPhotoIndex
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .systemGray5
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    // MARK: - Initializers
    init(viewModel: SnapComparisonSheetViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupLayout()
        setupPageViewController()
        setupPageControl()
        setupBindings()
        updateUI()
    }
    
    // MARK: - Methods
    private func setupLayout() {
        view.addSubviews([
            snapDateLabel,
            leftArrowButton,
            rightArrowButton
        ])
        
        NSLayoutConstraint.activate([
            snapDateLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            snapDateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            snapDateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
            
            // 왼쪽 화살표 버튼
            leftArrowButton.topAnchor.constraint(equalTo: snapDateLabel.topAnchor),
            leftArrowButton.trailingAnchor.constraint(equalTo: snapDateLabel.leadingAnchor, constant: -10),
            leftArrowButton.widthAnchor.constraint(equalToConstant: 30),
            leftArrowButton.heightAnchor.constraint(equalToConstant: 30),
            
            // 오른쪽 화살표 버튼
            rightArrowButton.topAnchor.constraint(equalTo: snapDateLabel.topAnchor),
            rightArrowButton.leadingAnchor.constraint(equalTo: snapDateLabel.trailingAnchor, constant: 10),
            rightArrowButton.widthAnchor.constraint(equalToConstant: 30),
            rightArrowButton.heightAnchor.constraint(equalToConstant: 30)
            
        ])
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if let startViewController = viewControllerAt(index: viewModel.selectedIndex) {
            pageViewController.setViewControllers([startViewController], direction: .forward, animated: true, completion: nil)
        }
        
        addChild(pageViewController)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: snapDateLabel.bottomAnchor, constant: 20),
            pageViewController.view.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupPageControl() {
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.updateUI = { [weak self] in
            self?.updateUI()
        }
        
        viewModel.updatePageControl = { [weak self] currentPage, numberOfPages in
            self?.pageControl.currentPage = currentPage
            self?.pageControl.numberOfPages = numberOfPages
        }
        
        viewModel.updateArrowVisibility = { [weak self] isLeftHidden, isRightHidden in
            self?.leftArrowButton.isHidden = isLeftHidden
            self?.rightArrowButton.isHidden = isRightHidden
        }
    }
    
    private func updateUI() {
        snapDateLabel.text = viewModel.currentSnap.date
        pageControl.numberOfPages = viewModel.currentSnap.images.count
        pageControl.currentPage = viewModel.currentPhotoIndex
        
        // 화살표 버튼 숨김
        leftArrowButton.isHidden = viewModel.isLeftArrowHidden
        rightArrowButton.isHidden = viewModel.isRightArrowHidden
    }
    /// 인덱스에 해당하는 SnapPhotoViewController 나타내는 메소드
    private func viewControllerAt(index: Int) -> UIViewController? {
        guard let image = viewModel.getSnapPhoto(at: index) else { return nil }
        let photoViewController = SnapPhotoViewController()
        photoViewController.image = image
        photoViewController.index = index
        return photoViewController
    }
    
    @objc private func didTapLeftArrow() {
        viewModel.moveToPreviousSnap()
        
        if let viewController = viewControllerAt(index: viewModel.currentPhotoIndex) {
            // PageViewController에서 보여줄 ViewController들을 설정
            pageViewController.setViewControllers([viewController], direction: .reverse, animated: true, completion: nil)
        }
    }
    
    @objc private func didTapRightArrow() {
        viewModel.moveToNextSnap()
        
        if let viewController = viewControllerAt(index: viewModel.currentPhotoIndex) {
            // PageViewController에서 보여줄 ViewController들을 설정해주는 메소드
            pageViewController.setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
        }
    }
}

// MARK: - UIPageViewControllerDelegate, Datasource Methods
extension SnapComparisonSheetViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? SnapPhotoViewController else { return nil }
        let index = viewController.index
        return viewControllerAt(index: index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? SnapPhotoViewController else { return nil }
        let index = viewController.index
        return viewControllerAt(index: index + 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let viewController = pageViewController.viewControllers?.first as? SnapPhotoViewController {
            viewModel.currentPhotoIndex = viewController.index
            viewModel.updateSnapData()
        }
    }
}
