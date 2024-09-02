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
    var snapData: [Snap] { get set }
    var filteredSnapData: [Snap] { get }
    var snapPhotoSelectionType: String { get set }
    var snapPeriodType: String { get set }
    var numberOfSections: Int { get }
    var snapPhotoMenuItems: [UIAction] { get }
    var snapPeriodMenuItems: [UIAction] { get }
    var snapDateMenuItems: [UIAction] { get set }
    
    var reloadCollectionView: (() -> Void)? { get set }
    var updateSnapPhotoButtonTitle: ((String) -> Void)? { get set }
    var updateSnapPeriodButtonTitle: ((String) -> Void)? { get set }
    var updateSnapDateButtonTitle: ((String) -> Void)? { get set }
    var categoryisEmpty: (() -> Void)? { get set }
    var snapisEmpty: (() -> Void)? { get set }
    var showSnapCollectionView: (() -> Void)? { get set }
    var updateMenu: (() -> Void)? { get set }
    
    func filterSnaps()
    func item(at indexPath: IndexPath) -> Snap
    func changeSnapPhotoSelection(type: String, completion: @escaping () -> Void)
    func changeSnapPeriod(type: String, completion: @escaping () -> Void)
    func changeSnapDate(date: Date, completion: @escaping () -> Void)
    func numberOfRows(in section: Int) -> Int
    func loadSanpstoFireStore(to categoryId: String)
    func filterSnapsByPeriod(_ snaps: [Snap], periodType: String) -> [Snap]
    func categoryDidChange(to newCategoryId: String?)
}

class SnapComparisonViewModel: SnapComparisonViewModelProtocol {
    
    // MARK: - Properties
    private let snapService = SnapService()
    private let categoryId = UserDefaults.standard.string(forKey: "currentCategoryId")
    
    var snapData: [Snap] = []
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
    
    /// 스냅 기준 선택 메뉴
    var snapDateMenuItems: [UIAction] = []
    
    /// 기준 스냅 선택 메뉴
    private var selectedDate: Date? {
        didSet {
            filterSnaps()
            if let date = selectedDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "yy년 MM월 d일"
                updateSnapDateButtonTitle?(formatter.string(from: date))
            } else {
                updateSnapDateButtonTitle?("날짜 선택")
            }
        }
    }
    
    // MARK: - Closures
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
    /// 버튼의 메뉴를 업데이트 하는 클로저
    var updateMenu: (() -> Void)?
    
    // MARK: - Initializer
    init() {
        if let categoryId = categoryId {
            loadSanpstoFireStore(to: categoryId)
            self.filterSnaps()
        } else {
            categoryisEmpty?()
        }
    }
    
    // MARK: - Methods
    /// 스냅 데이터 필터링 메소드
    func filterSnaps() {
        
        guard !snapData.isEmpty else {
            filteredSnapData = []
            snapisEmpty?()
            return
        }
        
        filteredSnapData = snapData
        
        if let selectedDate = selectedDate {
            // 선택한 날짜를 기준으로 과거 스냅 필터링
            filteredSnapData = filteredSnapData.filter { snap in
                guard let snapDate = snap.createdAt else { return false }
                return snapDate <= selectedDate
            }
            
            // 기간 필터링이 있는 경우
            if snapPeriodType != "전체" {
                filteredSnapData = filterSnapsByPeriod(filteredSnapData, periodType: snapPeriodType)
            }
            
            // 선택된 날짜의 스냅이 포함되지 않았으면 맨 앞에 추가
            if !filteredSnapData.contains(where: { Calendar.current.isDate($0.createdAt ?? Date(), inSameDayAs: selectedDate) }) {
                if let selectedSnap = snapData.first(where: { Calendar.current.isDate($0.createdAt ?? Date(), inSameDayAs: selectedDate) }) {
                    filteredSnapData.insert(selectedSnap, at: 0)
                }
            }
        } else if snapPeriodType != "전체" {
            // 선택된 날짜가 없고 기간 필터링이 있는 경우
            filteredSnapData = filterSnapsByPeriod(filteredSnapData, periodType: snapPeriodType)
        }
                
        if snapPhotoSelectionType == "메인" {
            filteredSnapData = filteredSnapData.map({ snap in
                let mainImage = snap.imageUrls.first.map { [$0] } ?? []
                guard let createdAt = snap.createdAt else { return Snap(imageUrls: [], createdAt: Date()) }
                return Snap(imageUrls: mainImage, createdAt: createdAt)
            })
        }
        
        // 과거의 스냅부터 보여주기 위한 정렬
        filteredSnapData.sort { ($0.createdAt ?? Date()) > ($1.createdAt ?? Date()) }
        
        if filteredSnapData.isEmpty {
            snapisEmpty?()
        } else {
            showSnapCollectionView?()
        }
    }
    
    func filterSnapsByPeriod(_ snaps: [Snap], periodType: String) -> [Snap] {
        // 기준이 되는 날짜
        guard let firstSnapDate = snaps.first?.createdAt else { return snaps }
        
        var filteredSnaps: [Snap] = []
        var standardDate: Date = firstSnapDate
        
        for snap in snaps.dropFirst() { // 첫번째 스냅은 포함, 따라서 제외 (중복 방지)
            guard let date = snap.createdAt else { return snaps }
            
            let shouldInclude: Bool
            switch periodType {
            case "일주일":
                // 기준 스냅과 일주일 간격이라면
                shouldInclude = date >= Calendar.current.date(byAdding: .day, value: 7, to: standardDate) ?? date
            case "한달":
                // 기준 스냅과 한달 간격이라면
                shouldInclude = date >= Calendar.current.date(byAdding: .month, value: 1, to: standardDate) ?? date
            case "일년":
                // 기준 스냅과 일년 간격이라면
                shouldInclude = date >= Calendar.current.date(byAdding: .year, value: 1, to: standardDate) ?? date
            default:
                shouldInclude = true
            }
            
            if shouldInclude {
                filteredSnaps.append(snap)
                standardDate = date // 새로운 기준 날짜로 업데이트
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
        filterSnaps()
        completion()
    }
    
    func numberOfRows(in section: Int) -> Int {
        1
    }
    
    /// 카테고리 변경시 호출되는 메소드
    func categoryDidChange(to newCategoryId: String?) {
        guard let newCategoryId = newCategoryId else { 
            // newCategoryId가 nil일 경우
            snapData = []
            filteredSnapData = []
            snapDateMenuItems = []
            updateSnapDateButtonTitle?("날짜 선택")
            categoryisEmpty?()
            return }
        print("[Snap비교] 스냅 비교뷰 카테고리 변경됨 \(newCategoryId)")
        loadSanpstoFireStore(to: newCategoryId)
        snapDateMenuItems = []
        updateSnapDateButtonTitle?("날짜 선택")
        updateMenu?()
        reloadCollectionView?()
    }
    
    /// Firebase Snap Load Method
    func loadSanpstoFireStore(to categoryId: String) {
        snapService.loadSnaps(userId: AuthViewModel.shared.currentUser?.uid ?? "", categoryId: categoryId) { result in
            switch result {
            case .success(let snaps):
                print("[FB] [Snap비교] 파이어베이스 스냅 로드")
                if snaps.isEmpty {
                    // 스냅이 없는 경우
                    print("[Snap비교] 카테고리는 존재, 스냅은 없음")
                    self.snapData = []
                    self.filteredSnapData = []
                    
                    // SnapDateButton의 메뉴 초기화
                    self.snapDateMenuItems = []
                    self.updateSnapDateButtonTitle?("날짜 선택")
                    
                    self.snapisEmpty?()
                } else {
                    print("[Snap비교] 카테고리, 스냅 존재")
                    self.snapData = snaps
                    self.filterSnaps()
                    // SnapDateButton의 메뉴를 다시 설정
                    self.snapDateMenuItems = self.createSnapDateMenuItems(from: snaps)
                    self.updateSnapDateButtonTitle?("날짜 선택")
                    self.showSnapCollectionView?()
                }
            case.failure(let error):
                print("[Snap비교] Failed to load snaps: \(error.localizedDescription)")
                self.snapData = []
                self.snapDateMenuItems = []
                self.updateSnapDateButtonTitle?("날짜 선택")
                self.snapisEmpty?()
            }
        }
    }
    
    private func createSnapDateMenuItems(from snaps: [Snap]) -> [UIAction] {
        return snaps.compactMap { snap in
            guard let date = snap.createdAt else { return nil }
            let formatter = DateFormatter()
            formatter.dateFormat = "yy년 MM월 d일"
             return UIAction(
                title: formatter.string(from: date),
                handler: { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.changeSnapDate(date: date) {
                            self?.updateSnapDateButtonTitle?(formatter.string(from: date))
                            self?.reloadCollectionView?()
                        }
                    }
                })
        }
    }
}
