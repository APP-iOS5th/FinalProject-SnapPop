//
//  CustomNavigationBarViewModel.swift
//  SnapPop
//
//  Created by 정종원 on 8/19/24.
//

import Foundation

protocol CategoryChangeDelegate: AnyObject {
    func categoryDidChange(to newCategoryId: String)
}

protocol CustomNavigationBarViewModelProtocol {
    var categories: [Category] { get set }
    var currentCategory: Category? { get set }
    var categoryisUpdated: (() -> Void)? { get set }
    func loadCategories(completion: @escaping () -> Void)
    func saveCategory(category: Category, completion: @escaping () -> Void)
    func updateCategory(categoryId: String, category: Category, completion: @escaping () -> Void)
    func deleteCategory(at index: Int, completion: @escaping (String?) -> Void)
    func selectCategory(at index: Int)
    func handleCategoryId(completion: @escaping (String) -> Void)
}

class CustomNavigationBarViewModel: CustomNavigationBarViewModelProtocol {
    
    // MARK: - Properties
    var categories: [Category] = []
    var currentCategory: Category?
    var categoryisUpdated: (() -> Void)?
    weak var delegate: CategoryChangeDelegate?
    
    private let categoryService = CategoryService()
    
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
        
        categoryService.deleteCategory(categoryId: categoryId) { error in
            if let error = error {
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
                        self.categoryisUpdated?()
                        completion("카테고리를 추가해 주세요")
                    } else {
                        // 카테고리가 남아있는 경우 첫 번째 카테고리를 선택
                        self.currentCategory = self.categories.first
                        UserDefaults.standard.set(self.categories.first?.id, forKey: "currentCategoryId")
                        self.categoryisUpdated?()
                        completion(self.currentCategory?.title)
                    }
                } else {
                    // 현재 선택된 카테고리가 삭제된 카테고리가 아닌 경우
                    self.categoryisUpdated?()
                    completion(nil)
                }
            }
        }
    }
    
    func selectCategory(at index: Int) {
        guard index >= 0 && index < categories.count else { return }
        UserDefaults.standard.set(categories[index].id, forKey: "currentCategoryId")
        delegate?.categoryDidChange(to: String(categories[index].id ?? ""))
        self.currentCategory = categories[index]
    }
        
    func handleCategoryId(completion: @escaping (String) -> Void) {
        loadCategories { [weak self] in
            guard let self = self else { return }
            
            var title: String
            
            if self.categories.isEmpty {
                // 카테고리id가 없는 경우
                title = "카테고리를 추가해 주세요"
                UserDefaults.standard.removeObject(forKey: "currentCategoryId")
            } else {
                // 카테고리id가 있는 경우
                if let savedCategoryId = UserDefaults.standard.string(forKey: "currentCategoryId"),
                   let savedCategory = self.categories.first(where: { $0.id == savedCategoryId }) {
                    // 저장된 카테고리id가 있고, 해당 카테고리가 존재하는 경우
                    self.currentCategory = savedCategory
                    title = savedCategory.title
                } else {
                    // 저장된 카테고리id가 있고, 저장된id의 카테고리가 존재하지 않는 경우
                    self.currentCategory = self.categories.first
                    title = self.categories.first?.title ?? "No Categories"
                    UserDefaults.standard.set(self.currentCategory?.id, forKey: "currentCategoryId")
                }
            }
            
            self.categoryisUpdated?()
            completion(title)
        }
    }
    
}
