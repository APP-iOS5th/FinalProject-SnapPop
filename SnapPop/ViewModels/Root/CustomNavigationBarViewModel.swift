//
//  CustomNavigationBarViewModel.swift
//  SnapPop
//
//  Created by 정종원 on 8/19/24.
//

import Foundation

protocol CategoryChangeDelegate: AnyObject {
    func categoryDidChange(to newCategoryId: String?)
}

protocol CustomNavigationBarViewModelProtocol {
    var categories: [Category] { get set }
    var currentCategory: Category? { get set }
    var categoryisUpdated: (() -> Void)? { get set }
    var delegate: CategoryChangeDelegate? { get set }
    func loadCategories(completion: @escaping () -> Void)
    func saveCategory(category: Category, completion: @escaping () -> Void)
    func updateCategory(categoryId: String, category: Category, completion: @escaping () -> Void)
    func deleteCategory(at index: Int, completion: @escaping (String?) -> Void)
    func selectCategory(at index: Int)
    func handleCategoryId(completion: @escaping (String) -> Void)
    func registerAllNotifications(for categoryId: String)
    func removeAllNotifications(for categoryId: String)
}

class CustomNavigationBarViewModel: CustomNavigationBarViewModelProtocol {
    
    // MARK: - Properties
    var categories: [Category] = []
    var currentCategory: Category?
    var categoryisUpdated: (() -> Void)?
    weak var delegate: CategoryChangeDelegate?
    
    private let categoryService = CategoryService()
    private let snapService = SnapService()
    private let managementService = ManagementService()
    
    // MARK: - Methods
    func loadCategories(completion: @escaping () -> Void) {
        categoryService.loadCategories { result in
            switch result {
            case .success(let categories):
                if categories.isEmpty {
                    // 파이어베이스에 카테고리가 없는 경우
                    print("파이어베이스에 카테고리가 없음")
                } else {
                    self.categories = categories
                    self.categoryisUpdated?()
                    completion()
                }
            case .failure(let error):
                print("Failed to load categories: \(error.localizedDescription)")
            }
        }
    }
    
    func saveCategory(category: Category, completion: @escaping () -> Void) {
        categoryService.saveCategory(category: category) { result in
            switch result {
            case .success(let savedCategory):
                print("success save Category")
                self.categories.append(savedCategory)
                self.categoryisUpdated?()
                completion()
            case .failure(let error):
                print("Failed to save error: \(error.localizedDescription)")
                completion()
            }
        }
    }
    
    func updateCategory(categoryId: String, category: Category, completion: @escaping () -> Void) {
        categoryService.updateCategory(categoryId: categoryId, updatedCategory: category) { result in
            switch result {
            case .success:
                self.categoryisUpdated?()
                completion()
            case .failure(let error):
                print("Failed to save error: \(error.localizedDescription)")
                completion()
            }
        }
    }
    
    func deleteCategory(at index: Int, completion: @escaping (String?) -> Void) {
        guard index >= 0 && index < categories.count else {
            return }
        guard let categoryId = categories[index].id else {
            return }
        
        let tempCategory = categories[index]
        categories.remove(at: index)
        
        snapService.deleteSnaps(categoryId: categoryId) { error in
            if let error = error {
                print("[네비게이션바VM] Failed to deleteSnaps: \(error.localizedDescription)")
            } else {
                self.categoryService.deleteCategory(categoryId: categoryId) { error in
                    if let error = error {
                        // TODO: - 카테고리는 다시 생기지만 Snaps는 삭제됨..
                        print("Failed to delete category: \(error.localizedDescription)")
                        self.categories.insert(tempCategory, at: index)
                        self.categoryisUpdated?()
                        completion(nil)
                    } else {
                        print("Successfully deleted category")
                        // 현재 선택된 카테고리가 삭제된 카테고리인 경우
                        if self.currentCategory?.id == categoryId {
                            if self.categories.isEmpty {
                                // 카테고리가 남아있지 않은 경우
                                self.currentCategory = nil
                                UserDefaults.standard.removeObject(forKey: "currentCategoryId")
                                print("카테고리가 남아있지 않은 경우 삭제 후의 Current UserDefaults: \(String(describing: UserDefaults.standard.string(forKey: "currentCategoryId")))")
                                //                                self.delegate?.categoryDidChange(to: nil)
                                NotificationCenter.default.post(name: .categoryDidChange, object: nil, userInfo: nil)
                                completion("카테고리를 추가해 주세요")
                            } else {
                                // 카테고리가 남아있는 경우 첫 번째 카테고리를 선택
                                self.currentCategory = self.categories.first
                                if let newCategoryId = self.currentCategory?.id {
                                    UserDefaults.standard.set(newCategoryId, forKey: "currentCategoryId")
                                    //                                    self.delegate?.categoryDidChange(to: newCategoryId)
                                    if let selectedCategory = self.currentCategory {
                                        NotificationCenter.default.post(name: .categoryDidChange, object: nil, userInfo: ["categoryId": newCategoryId])
                                    }
                                    print("카테고리가 남아있는 경우 첫 번째 카테고리를 선택 경우 삭제 후의 Current UserDefaults: \(String(describing: UserDefaults.standard.string(forKey: "currentCategoryId")))")
                                }
                                completion(self.currentCategory?.title)
                            }
                        } else {
                            // 현재 선택된 카테고리가 삭제된 카테고리가 아닌 경우
                            if let firstCategory = self.categories.first {
                                self.currentCategory = firstCategory
                                if let newCategoryId = firstCategory.id {
                                    UserDefaults.standard.set(newCategoryId, forKey: "currentCategoryId")
                                    //                                    self.delegate?.categoryDidChange(to: newCategoryId)
                                    if let selectedCategory = self.currentCategory {
                                        NotificationCenter.default.post(name: .categoryDidChange, object: nil, userInfo: ["categoryId": newCategoryId])
                                    }
                                    print("현재 선택된 카테고리가 삭제된 카테고리가 아닌 경우 삭제 후의 Current UserDefaults: \(String(describing: UserDefaults.standard.string(forKey: "currentCategoryId")))")
                                }
                                completion(firstCategory.title)
                            } else {
                                // categories 배열이 비어있는 경우
                                self.currentCategory = nil
                                UserDefaults.standard.removeObject(forKey: "currentCategoryId")
                                print("categories 배열이 비어있는 경우 삭제 후의 Current UserDefaults: \(String(describing: UserDefaults.standard.string(forKey: "currentCategoryId")))")
                                //                                self.delegate?.categoryDidChange(to: nil)
                                NotificationCenter.default.post(name: .categoryDidChange, object: nil, userInfo: nil)
                                completion("카테고리를 추가해 주세요")
                            }
                        }
                    }
                }
            }
            
        } // deleteSnaps
        
        self.categoryisUpdated?()
    }
    
    func selectCategory(at index: Int) {
        guard index >= 0 && index < categories.count else { return }
        guard let categoryId = categories[index].id else { return }
        UserDefaults.standard.set(categoryId, forKey: "currentCategoryId")
        //        delegate?.categoryDidChange(to: String(categoryId))
        self.currentCategory = categories[index]
        
        NotificationCenter.default.post(name: .categoryDidChange, object: nil, userInfo: ["categoryId": categoryId])
        
        print("selectCategory Current UserDefaults: \(String(describing: UserDefaults.standard.string(forKey: "currentCategoryId")))")
    }
    
    func handleCategoryId(completion: @escaping (String) -> Void) {
        loadCategories { [weak self] in
            guard let self = self else { return }
            
            var title: String
            
            if self.categories.isEmpty {
                // 카테고리id가 없는 경우
                title = "카테고리를 추가해 주세요"
                UserDefaults.standard.removeObject(forKey: "currentCategoryId")
                NotificationCenter.default.post(name: .categoryDidChange, object: nil, userInfo: nil)
            } else {
                // 카테고리id가 있는 경우
                if let savedCategoryId = UserDefaults.standard.string(forKey: "currentCategoryId"),
                   let savedCategory = self.categories.first(where: { $0.id == savedCategoryId }) {
                    // 저장된 카테고리id가 있고, 해당 카테고리가 존재하는 경우
                    self.currentCategory = savedCategory
                    title = savedCategory.title
                    NotificationCenter.default.post(name: .categoryDidChange, object: nil, userInfo: ["categoryId": savedCategoryId])
                } else {
                    // 저장된 카테고리id가 있고, 저장된id의 카테고리가 존재하지 않는 경우
                    self.currentCategory = self.categories.first
                    title = self.categories.first?.title ?? "No Categories"
                    UserDefaults.standard.set(self.currentCategory?.id, forKey: "currentCategoryId")
                    NotificationCenter.default.post(name: .categoryDidChange, object: nil, userInfo: ["categoryId": self.currentCategory?.id])
                }
            }
            
            self.categoryisUpdated?()
            completion(title)
        }
    }
    
    /// 모든 알림 제거
    func removeAllNotifications(for categoryId: String) {
        managementService.loadManagements(categoryId: categoryId) { result in
            switch result {
            case .success(let managements):
                let identifiers = managements.filter { $0.alertStatus }.map { "initialNotification-\(categoryId)-\($0.id ?? "")" }
                NotificationManager.shared.removeNotification(identifiers: identifiers)
            case .failure(let error):
                print("Failed to load managements: \(error.localizedDescription)")
            }
        }
    }
    
    /// 모든 알림 등록
    func registerAllNotifications(for categoryId: String) {
        managementService.loadManagements(categoryId: categoryId) { result in
            switch result {
            case .success(let managements):
                managements.forEach { management in
                    if management.alertStatus {
                        if management.repeatCycle != 0 {
                            // 반복이 없는 알림 추가
                            NotificationManager.shared.initialNotification(categoryId: categoryId,
                                                                           managementId: management.id ?? "",
                                                                           startDate: management.startDate,
                                                                           alertTime: management.alertTime,
                                                                           repeatCycle: management.repeatCycle,
                                                                           body: management.title)
                        } else {
                            // 반복이 있는 알림 추가
                            NotificationManager.shared.repeatingNotification(categoryId: categoryId,
                                                                             managementId: management.id ?? "",
                                                                             startDate: management.startDate,
                                                                             alertTime: management.alertTime,
                                                                             repeatCycle: management.repeatCycle,
                                                                             body: management.title)
                        }
                    }
                }
            case .failure(let error):
                print("Failed to load managements: \(error.localizedDescription)")
            }
        }
    }
    
}
