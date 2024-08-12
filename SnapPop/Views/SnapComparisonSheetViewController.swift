//
//  SnapComparisonSheetViewController.swift
//  SnapPop
//
//  Created by 정종원 on 8/9/24.
//

import UIKit

class SnapComparisonSheetViewController: UIViewController {
    // MARK: - Properties
    var snapPhotos: [UIImage] = []
    var selectedIndex: Int = 0
    
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
        // TODO: didTapLeftArrow 메소드 구현
//        button.addTarget(self, action: #selector(didTapLeftArrow), for: .touchUpInside)
        return button
    }()

    /// 스냅 오른쪽 화살표 버튼
    private lazy var rightArrowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        // TODO: didTapRightArrow 메소드 구현
//        button.addTarget(self, action: #selector(didTapRightArrow), for: .touchUpInside)
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
            
            // 오른쪽 화살표 버튼
            rightArrowButton.topAnchor.constraint(equalTo: snapDateLabel.topAnchor),
            rightArrowButton.leadingAnchor.constraint(equalTo: snapDateLabel.trailingAnchor, constant: 10)
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
        view.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: snapDateLabel.bottomAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        pageViewController.didMove(toParent: self)
    }
    
    private func setupPageControl() {
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: pageViewController.view.bottomAnchor, constant: 10),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func viewControllerAt(index: Int) -> UIViewController? {
        guard index >= 0 && index < snapPhotos.count else { return nil }
        let photoViewController = SnapPhotoViewController()
        photoViewController.image = snapPhotos[index]
        photoViewController.index = index
        return photoViewController
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
            pageControl.currentPage = viewController.index
        }
    }
}
