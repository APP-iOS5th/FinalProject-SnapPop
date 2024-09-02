//
//  SnapExpandSheetViewController.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/29/24.
//

import UIKit
import Kingfisher

class SnapExpandSheetViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // MARK: - Properties
    var imageUrls: [String] // 스냅 이미지 URL 배열
    var currentIndex: Int // 현재 인덱스

    // MARK: - UIComponents
    private var pageViewController: UIPageViewController = {
        let pageVC = UIPageViewController()
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        return pageVC
    }()
    
    /// 페이지 컨트롤
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = imageUrls.count
        pageControl.currentPage = currentIndex
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .systemGray5
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    // MARK: - Initializers
    init(imageUrls: [String], currentIndex: Int) {
        self.imageUrls = imageUrls
        self.currentIndex = currentIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customBackgroundColor
        setupPageViewController() // 페이지 뷰 컨트롤러 설정
        setupPageControll() // 페이지 컨트롤 설정
        setupPageControllIndex()
    }
    
    // MARK: - Methods
    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if let startViewController = viewControllerAt(index: currentIndex) {
            pageViewController.setViewControllers([startViewController], direction: .forward, animated: true, completion: nil)
        }
        
        addChild(pageViewController)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            pageViewController.view.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupPageControll() {
        view.addSubviews([
            pageControl
        ])
        
        NSLayoutConstraint.activate([
            // 페이지 컨트롤
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupPageControllIndex() {
        pageControl.numberOfPages = imageUrls.count
        pageControl.currentPage = currentIndex
    }
    
    private func updateUI() {
        pageControl.currentPage = currentIndex // 페이지 컨트롤 업데이트
    }
    
    private func viewControllerAt(index: Int) -> UIViewController? {
        guard index >= 0, index < imageUrls.count else { return nil }
        
        let viewController = UIViewController()
        viewController.view.tag = index // tag 속성을 인덱스로 설정

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(imageView)
        
        // 이미지 뷰 레이아웃 설정
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: viewController.view.topAnchor, constant: 20), // 상단 패딩
            imageView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor, constant: -20), // 하단 패딩
            imageView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 20), // 왼쪽 패딩
            imageView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -20) // 오른쪽 패딩
        ])
        
        // Kingfisher를 사용하여 이미지 로드
        if let url = URL(string: imageUrls[index]) {
            imageView.kf.setImage(with: url)
        }
        
        return viewController
    }
    
    // MARK: - UIPageViewControllerDataSource Methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let previousIndex = currentIndex - 1
        return viewControllerAt(index: previousIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let nextIndex = currentIndex + 1
        return viewControllerAt(index: nextIndex)
    }
    
    // MARK: - UIPageViewControllerDelegate Methods
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let visibleViewController = pageViewController.viewControllers?.first,
           let index = viewControllersIndex(of: visibleViewController) {
            currentIndex = index
            updateUI()
        }
    }
    
    private func viewControllersIndex(of viewController: UIViewController) -> Int? {
        return viewController.view.tag
    }
}
