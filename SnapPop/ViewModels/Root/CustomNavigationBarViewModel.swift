//
//  CustomNavigationBarViewModel.swift
//  SnapPop
//
//  Created by 정종원 on 8/19/24.
//

import Foundation

protocol CustomNavigationBarViewModelProtocol {
    var categories: [Category] { get set }
    var currentCategory: Category? { get set }
    var categoryisUpdated: (() -> Void)? { get set }
    func loadCategories(completion: @escaping () -> Void)
    func saveCategory(category: Category, completion: @escaping () -> Void)
    func updateCategory(categoryId: String, category: Category, completion: @escaping () -> Void)
    func deleteCategory(at index: Int, completion: @escaping () -> Void)
    func selectCategory(at index: Int)
}

class CustomNavigationBarViewModel: CustomNavigationBarViewModelProtocol {
    
    // MARK: - Properties
    var categories: [Category] = []
    var currentCategory: Category?
    var categoryisUpdated: (() -> Void)?
    
    private let categoryService = CategoryService()
    
    // MARK: - Methods
    func loadCategories(completion: @escaping () -> Void) {
        categoryService.loadCategories { result in
            switch result {
            case .success(let categories):
                if categories.isEmpty {
                    // TODO: - 파이어베이스에 카테고리가 없을 경우
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
    
    func deleteCategory(at index: Int, completion: @escaping () -> Void) {
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
                completion()
            } else {
                print("Successfully deleted category")
                self.categoryisUpdated?()
                completion()
            }
        }
    }
    
    func selectCategory(at index: Int) {
        guard index >= 0 && index < categories.count else { return }
        // TODO: - 카테고리 삭제했을 경우 해당 인덱스 일경우일때
        UserDefaults.standard.set(categories[index].id, forKey: "currentCategoryId")
        self.currentCategory = categories[index]
    }
        
}
