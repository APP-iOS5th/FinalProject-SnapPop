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
    
    /// 왼쪽 화살표 버튼
    private lazy var leftArrowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapLeftArrow), for: .touchUpInside)
        return button
    }()
    
    /// 오른쪽 화살표 버튼
    private lazy var rightArrowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapRightArrow), for: .touchUpInside)
        return button
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
            leftArrowButton,
            rightArrowButton,
            pageControl
        ])
        
        NSLayoutConstraint.activate([
            // 왼쪽 화살표 버튼
            leftArrowButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            leftArrowButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            leftArrowButton.widthAnchor.constraint(equalToConstant: 30),
            leftArrowButton.heightAnchor.constraint(equalToConstant: 30),
            
            // 오른쪽 화살표 버튼
            rightArrowButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            rightArrowButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            rightArrowButton.widthAnchor.constraint(equalToConstant: 30),
            rightArrowButton.heightAnchor.constraint(equalToConstant: 30),
            
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
        // 화살표 버튼 상태 업데이트
        leftArrowButton.isHidden = currentIndex == 0
        rightArrowButton.isHidden = currentIndex == imageUrls.count - 1
        pageControl.currentPage = currentIndex // 페이지 컨트롤 업데이트
    }
    
    private func viewControllerAt(index: Int) -> UIViewController? {
        guard index >= 0, index < imageUrls.count else { return nil }
        
        let viewController = UIViewController()
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
    
    @objc private func didTapLeftArrow() {
        if currentIndex > 0 {
            currentIndex -= 1
            if let viewController = viewControllerAt(index: currentIndex) {
                pageViewController.setViewControllers([viewController], direction: .reverse, animated: true, completion: nil)
            }
            updateUI()
        }
    }
    
    @objc private func didTapRightArrow() {
        if currentIndex < imageUrls.count - 1 {
            currentIndex += 1
            if let viewController = viewControllerAt(index: currentIndex) {
                pageViewController.setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
            }
            updateUI()
        }
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
        // 현재 보여지고 있는 뷰 컨트롤러의 인덱스를 찾기 위해
        // 먼저, 모든 이미지 뷰 컨트롤러를 비교하여 해당 인덱스를 찾습니다
        guard let imageView = viewController.view.subviews.compactMap({ $0 as? UIImageView }).first,
              let image = imageView.image else {
            return nil
        }
        
        // URL과 이미지 데이터를 비교하는 것은 비효율적일 수 있으므로
        // index를 저장하고 관리하는 방법을 추천합니다.
        return imageUrls.firstIndex(where: { url in
            if let url = URL(string: url),
               let imageData = try? Data(contentsOf: url),
               let imageDataFromURL = image.pngData() ?? image.jpegData(compressionQuality: 1.0) {
                return imageData == imageDataFromURL
            }
            return false
        })
    }
}
