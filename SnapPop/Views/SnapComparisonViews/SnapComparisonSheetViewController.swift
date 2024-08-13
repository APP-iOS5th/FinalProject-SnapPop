//
//  SnapComparisonSheetViewController.swift
//  SnapPop
//
//  Created by 정종원 on 8/9/24.
//

import UIKit

class SnapComparisonSheetViewController: UIViewController {
    // MARK: - Properties
    var viewModel: SnapComparisonViewModel?
    var snapPhotos: [UIImage] = []
    var selectedIndex: Int = 0
    var currentDateIndex: Int = 0
    var currentPhotoIndex: Int = 0
    private var currentSnap: Snap? {
        return viewModel?.filteredSnapData[currentDateIndex]
    }
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
        pageControl.numberOfPages = snapPhotos.count
        pageControl.currentPage = selectedIndex
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .systemGray5
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupLayout()
        setupPageViewController()
        setupPageControl()
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
        
        if let startViewController = viewControllerAt(index: selectedIndex) {
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
    
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        guard let currentSnap = currentSnap else { return }
        snapDateLabel.text = currentSnap.date
        pageControl.numberOfPages = currentSnap.images.count
        pageControl.currentPage = currentPhotoIndex
        
        // 화살표 버튼 숨김
        leftArrowButton.isHidden = currentDateIndex == 0
        rightArrowButton.isHidden = currentDateIndex == viewModel.filteredSnapData.count - 1
    }
    
    private func viewControllerAt(index: Int) -> UIViewController? {
        guard index >= 0 && index < snapPhotos.count else { return nil }
        let photoViewController = SnapPhotoViewController()
        photoViewController.image = snapPhotos[index]
        photoViewController.index = index
        return photoViewController
    }
    
    @objc private func didTapLeftArrow() {
        guard let viewModel = viewModel else { return }
        if currentDateIndex > 0 {
            currentDateIndex -= 1
            currentPhotoIndex = 0
            snapPhotos = viewModel.filteredSnapData[currentDateIndex].images
            updateUI()
            if let viewController = viewControllerAt(index: currentPhotoIndex) {
                pageViewController.setViewControllers([viewController], direction: .reverse, animated: true, completion: nil)
            }
        }
    }
    
    @objc private func didTapRightArrow() {
        guard let viewModel = viewModel else { return }
        if currentDateIndex < viewModel.filteredSnapData.count - 1 {
            currentDateIndex += 1
            currentPhotoIndex = 0
            snapPhotos = viewModel.filteredSnapData[currentDateIndex].images
            updateUI()
            if let viewController = viewControllerAt(index: currentPhotoIndex) {
                pageViewController.setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
            }
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
            currentPhotoIndex = viewController.index
            pageControl.currentPage = currentPhotoIndex
        }
    }
}
