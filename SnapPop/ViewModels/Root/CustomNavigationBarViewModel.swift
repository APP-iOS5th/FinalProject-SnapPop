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
    func loadCategories(completion: @escaping () -> Void)
    func selectCategory(at index: Int)
}

class CustomNavigationBarViewModel: CustomNavigationBarViewModelProtocol {
    
    // MARK: - Properties
    var categories: [Category] = []
    var currentCategory: Category?

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
                    completion()
                }
            case .failure(let error):
                print("Failed to load categories: \(error.localizedDescription)")
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

