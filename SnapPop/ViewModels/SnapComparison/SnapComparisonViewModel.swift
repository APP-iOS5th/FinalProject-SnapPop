//
//  SnapComparisonViewModel.swift
//  SnapPop
//
//  Created by 정종원 on 8/8/24.
//

import Foundation
import UIKit

// MARK: - Protocols
protocol SnapComparisonViewModelProtocol {
    var filteredSnapData: [Snap] { get }
    var snapPhotoSelectionType: String { get set }
    var snapPeriodType: String { get set }
    var numberOfSections: Int { get }
    var snapPhotoMenuItems: [UIAction] { get }
    var snapPeriodMenuItems: [UIAction] { get }
    var snapDateMenuItems: [UIAction] { get }
    
    var reloadCollectionView: (() -> Void)? { get set }
    var updateSnapPhotoButtonTitle: ((String) -> Void)? { get set }
    var updateSnapPeriodButtonTitle: ((String) -> Void)? { get set }
    var updateSnapDateButtonTitle: ((String) -> Void)? { get set }
    var categoryisEmpty: (() -> Void)? { get set }
    var snapisEmpty: (() -> Void)? { get set }
    var showSnapCollectionView: (() -> Void)? { get set }
    
    func filterSnaps()
    func item(at indexPath: IndexPath) -> Snap
    func changeSnapPhotoSelection(type: String, completion: @escaping () -> Void)
    func changeSnapPeriod(type: String, completion: @escaping () -> Void)
    func changeSnapDate(date: Date, completion: @escaping () -> Void)
    func numberOfRows(in section: Int) -> Int
    func loadSanpstoFireStore(to categoryId: String)
    func filterSnapsByPeriod(_ snaps: [Snap], periodType: String) -> [Snap]
}

class SnapComparisonViewModel: SnapComparisonViewModelProtocol,
                               CategoryChangeDelegate {
    
    // MARK: - Properties
    private let snapService = SnapService()
    private let categoryId = UserDefaults.standard.string(forKey: "currentCategoryId")
    
    private var snapData: [Snap] = []
    var filteredSnapData: [Snap] = []
    var snapPhotoSelectionType: String = "전체" {
        didSet {
            filterSnaps()
            updateSnapPhotoButtonTitle?(snapPhotoSelectionType)
        }
    }
    var snapPeriodType: String = "전체" {
        didSet {
            filterSnaps()
            updateSnapPeriodButtonTitle?(snapPeriodType)
        }
    }
    var numberOfSections: Int {
        filteredSnapData.count
    }
   
    /// 기준 스냅 선택 메뉴
    var snapDateMenuItems: [UIAction] {
        snapData.compactMap { snap in
            guard let date = snap.createdAt else { return nil }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 MM월 d일"
            return UIAction(
                title: formatter.string(from: date),
                handler: { [weak self] _ in
                    self?.changeSnapDate(date: date) {
                        self?.reloadCollectionView?()
                    }
                })
        }
    }
    /// 스냅 사진 선택 메뉴
    var snapPhotoMenuItems: [UIAction] {
        let allSnapPhoto = UIAction(
            title: "전체",
            handler: { [weak self] _ in
                self?.changeSnapPhotoSelection(type: "전체") {
                    self?.reloadCollectionView?()
                }
            })
        
        let mainSnapPhoto = UIAction(
            title: "메인",
            handler: { [weak self] _ in
                self?.changeSnapPhotoSelection(type: "메인") {
                    self?.reloadCollectionView?()
                }
            })
        
        return [mainSnapPhoto, allSnapPhoto]
    }
    /// 스냅 주기 선택 메뉴
    var snapPeriodMenuItems: [UIAction] {
        let perWeek = UIAction(
            title: "일주일",
            handler: { [weak self] _ in
                self?.changeSnapPeriod(type: "일주일") {
                    self?.reloadCollectionView?()
                }
            })
        
        let perMonth = UIAction(
            title: "한달",
            handler: { [weak self] _ in
                self?.changeSnapPeriod(type: "한달") {
                    self?.reloadCollectionView?()
                }
            })
        
        let perYear = UIAction(
            title: "일년",
            handler: { [weak self] _ in
                self?.changeSnapPeriod(type: "일년") {
                    self?.reloadCollectionView?()
                }
            })
        
        let allPeriod = UIAction(
            title: "전체",
            handler: { [weak self] _ in
                self?.changeSnapPeriod(type: "전체") {
                    self?.reloadCollectionView?()
                }
            })
        
        return [perWeek, perMonth, perYear, allPeriod]
    }
    // 스냅 기준 선택 메뉴
    private var selectedDate: Date? {
        didSet {
            filterSnaps()
            if let date = selectedDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy년 MM월 d일"
                updateSnapDateButtonTitle?(formatter.string(from: date))
            } else {
                updateSnapDateButtonTitle?("날짜 선택")
            }
        }
    }
    /// 버튼 타이틀 업데이트 클로저
    var updateSnapPhotoButtonTitle: ((String) -> Void)?
    /// 버튼 타이틀 업데이트 클로저
    var updateSnapPeriodButtonTitle: ((String) -> Void)?
    /// 버튼 타이틀 업데이트 클로저
    var updateSnapDateButtonTitle: ((String) -> Void)?
    /// 카테고리가 비었을때 호출되는 클로저
    var categoryisEmpty: (() -> Void)?
    /// snap이 없을때 호출되는 클로저
    var snapisEmpty: (() -> Void)?
    /// CollectionView를 보여주는 클로저
    var showSnapCollectionView: (() -> Void)?
    /// 컬렉션뷰 reload 클로저
    var reloadCollectionView: (() -> Void)?
    
    // MARK: - Initializer
    init() {
        guard let categoryId = categoryId else {
            // Category Id가 없음
            categoryisEmpty?()
            return }
        loadSanpstoFireStore(to: categoryId)
        filterSnaps()
    }
    
    // MARK: - Methods
    /// 스냅 데이터 필터링 메소드
    func filterSnaps() {
        
        guard !snapData.isEmpty else {
            snapisEmpty?()
            return
        }
        filteredSnapData = filterSnapsByPeriod(snapData, periodType: snapPeriodType)
        
        if snapPhotoSelectionType == "메인 사진" {
            filteredSnapData = filteredSnapData.map({ snap in
                let mainImage = snap.imageUrls.first.map { [$0] } ?? []
                guard let createdAt = snap.createdAt else { return Snap(imageUrls: [], createdAt: Date()) }
                return Snap(imageUrls: mainImage, createdAt: createdAt)
            })
        }
        print("필터링된 스냅 개수: \(filteredSnapData.count)")
        
        if filteredSnapData.isEmpty {
            snapisEmpty?()
        } else {
            showSnapCollectionView?()
        }
        
        // 최신 순으로 보여주기
        filteredSnapData = filteredSnapData.reversed()
    }
    
    func filterSnapsByPeriod(_ snaps: [Snap], periodType: String) -> [Snap] {
        // 기준이 되는 날짜를 설정
        guard let firstSnapDate = selectedDate ?? snaps.first?.createdAt else { return snaps }
        
        var filteredSnaps: [Snap] = []
        var standardDate: Date = firstSnapDate
        
        for snap in snaps {
            guard let date = snap.createdAt else { return snaps }
            
            let shouldInclude: Bool
            switch periodType {
            case "일주일":
                // 기준 스냅과 일주일 간격이라면
                shouldInclude = Calendar.current.dateComponents([.day], from: standardDate, to: date).day ?? 0 >= 7
            case "한달":
                // 기준 스냅과 한달 간격이라면
                shouldInclude = Calendar.current.dateComponents([.month], from: standardDate, to: date).month ?? 0 >= 1
            case "일년":
                // 기준 스냅과 일년 간격이라면
                shouldInclude = Calendar.current.dateComponents([.year], from: standardDate, to: date).year ?? 0 >= 1
            default:
                shouldInclude = true
            }
            
            if shouldInclude {
                filteredSnaps.append(snap)
                standardDate = date // 새로운 기준 날짜로 업데이트
            }
        }
        
        // 선택된 기준 날짜의 스냅 데이터도 포함
        if let selectedDate = selectedDate, let snapForSelectedDate = snaps.first(where: { $0.createdAt == selectedDate }) {
            if !filteredSnaps.contains(where: { $0.createdAt == selectedDate }) {
                filteredSnaps.insert(snapForSelectedDate, at: 0)
            }
        }
        
        return filteredSnaps
    }
    
    func item(at indexPath: IndexPath) -> Snap {
        return filteredSnapData[indexPath.section]
    }
    
    /// snapPhotoSelectionType을 정해주는 메소드
    func changeSnapPhotoSelection(type: String, completion: @escaping () -> Void) {
        self.snapPhotoSelectionType = type
        completion()
    }
    
    /// snapPeriodType을 정해주는 메소드
    func changeSnapPeriod(type: String, completion: @escaping () -> Void) {
        self.snapPeriodType = type
        completion()
    }
    
    /// selectedDate를 정해주는 메소드
    func changeSnapDate(date: Date, completion: @escaping () -> Void) {
        self.selectedDate = date
        completion()
    }
    
    func numberOfRows(in section: Int) -> Int {
        1
    }
    
    /// 카테고리 변경시 호출되는 메소드
    func categoryDidChange(to newCategoryId: String) {
        print("[Snap비교] 스냅 비교뷰 카테고리 변경됨 \(newCategoryId)")
        loadSanpstoFireStore(to: newCategoryId)
        reloadCollectionView?()
    }
    
    /// Firebase Snap Load Method
    func loadSanpstoFireStore(to categoryId: String) {
        snapService.loadSnaps(categoryId: categoryId) { result in
            switch result {
            case .success(let snaps):
                print("[FB] [Snap비교] 파이어베이스 스냅 로드")
                if snaps.isEmpty {
                    // 스냅이 없는 경우
                    print("[Snap비교] 카테고리는 존재, 스냅은 없음")
                    self.snapisEmpty?()
                } else {
                    print("[Snap비교] 카테고리, 스냅 존재")
                    self.snapData = snaps
                    self.filterSnaps()
                    self.showSnapCollectionView?()
                }
            case.failure(let error):
                print("[Snap비교] Failed to load snaps: \(error.localizedDescription)")
            }
        }
    }
}
