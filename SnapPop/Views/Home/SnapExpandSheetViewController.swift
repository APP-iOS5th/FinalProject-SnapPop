//
//  SnapExpandSheetViewController.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/26/24.
//

import UIKit

class SnapExpandSheetViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // MARK: - Properties
    var imageUrls: [String] // 스냅 이미지 URL 배열
    var currentIndex: Int // 현재 인덱스

    // MARK: - UIComponents
    private var pageViewController: UIPageViewController!
    
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
        view.backgroundColor = .white
        
        setupPageViewController() // 페이지 뷰 컨트롤러 설정
        setupLayout() // 레이아웃 설정
        setupPageControl()
        updateUI()
        
        // 모달 시트 스타일 설정
        self.modalPresentationStyle = .pageSheet
        if let sheet = self.sheetPresentationController {
            sheet.detents = [.medium()] // 모달 크기 설정
            sheet.prefersGrabberVisible = true // 그랩바 표시
        }
    }
    
    // MARK: - Methods
    private func setupLayout() {
        view.addSubviews([
            pageControl
        ])
        
        NSLayoutConstraint.activate([
            // 페이지 컨트롤
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if let startViewController = viewControllerAt(index: currentIndex) {
            pageViewController.setViewControllers([startViewController], direction: .forward, animated: true, completion: nil)
        }
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.frame = view.bounds // 전체 화면에 맞게 설정
        pageViewController.didMove(toParent: self)
    }
    
    private func setupPageControl() {
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
        imageView.contentMode = .scaleAspectFit // 비율 유지
        imageView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(imageView)
        
        // 이미지 뷰 레이아웃 설정
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor)
        ])
        
        // 이미지 로드
        if let url = URL(string: imageUrls[index]) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            }
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
            updateUI() // UI 업데이트 호출
        }
    }
    
    private func viewControllersIndex(of viewController: UIViewController) -> Int? {
        return viewController.view.tag
    }
}
