//
//  CategoryService.swift
//  SnapPop
//
//  Created by 이인호 on 8/12/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

final class CategoryService {
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    private let snapService = SnapService()
    private let managementService = ManagementService()
    
    func saveCategory(category: Category, completion: @escaping (Result<Category, Error>) -> Void) {
        let documentRef = db.collection("Users")
            .document(AuthViewModel.shared.currentUser?.uid ?? "")
            .collection("Categories")
            .document()
        
        var categoryWithID = category
        categoryWithID.id = documentRef.documentID
        
        do {
            try documentRef.setData(from: categoryWithID) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(categoryWithID))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func loadCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        db.collection("Users")
            .document(AuthViewModel.shared.currentUser?.uid ?? "pKfnEhNFSYVTz0HE6w9QmDIzkBk2")
            .collection("Categories")
            .order(by: "title")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                
                let categories = documents.compactMap { document in
                    try? document.data(as: Category.self)
                }
                
                completion(.success(categories))
            }
    }
    
    func updateCategory(categoryId: String, updatedCategory: Category, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("Users")
                .document(AuthViewModel.shared.currentUser?.uid ?? "")
                .collection("Categories")
                .document(categoryId)
                .setData(from: updatedCategory, merge: true) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(()))
                }
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteCategory(userId: String, categoryId: String, completion: @escaping (Error?) -> Void) {
        db.collection("Users")
            .document(userId)
            .collection("Categories")
            .document(categoryId)
            .delete { error in
                if let error = error {
                    completion(error) // firestore에서 없는 문서를 삭제하려고 해도 에러를 반환하지 않도록 설계되어있음
                } else {
                    completion(nil)
                }
            }
    }
    
    // 카테고리 및 하위 데이터 삭제
    func deleteCategoryWithAllData(userId: String, categoryId: String, completion: @escaping (Error?) -> Void) {
        let group = DispatchGroup()

        // 1. Managements 삭제
        group.enter()
        managementService.deleteManagements(userId: userId, categoryId: categoryId) { result in
            switch result {
            case .success:
                print("Managements deleted successfully")
                group.leave()
            case .failure(let error):
                print("Failed to delete Managements: \(error.localizedDescription)")
                completion(error)
                group.leave()
                return
            }
        }

        // 2. Snaps 삭제
        group.enter()
        snapService.deleteSnaps(userId: userId, categoryId: categoryId) { error in
            if let error = error {
                print("Failed to delete Snaps: \(error.localizedDescription)")
                completion(error)
                group.leave()
                return
            }
            print("Snaps deleted successfully")
            group.leave()
        }

        // 3. 모든 하위 데이터가 삭제된 후 카테고리 삭제
        group.notify(queue: .main) {
            self.deleteCategory(userId: userId, categoryId: categoryId) { error in
                if let error = error {
                    print("Failed to delete category: \(error.localizedDescription)")
                    completion(error)
                } else {
                    print("Category deleted successfully")
                    completion(nil)
                }
            }
        }
    }
    
    // 유저가 가진 카테고리들 모두 삭제
    func deleteCategories(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentRef = db.collection("Users")
            .document(userId)
            .collection("Categories")
        
        documentRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            } else {
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    completion(.success(()))
                    return
                }
                
                let group = DispatchGroup()
                
                for document in documents {
                    group.enter()
                    self.deleteCategoryWithAllData(userId: userId, categoryId: document.documentID) { error in
                        if let error = error {
                            completion(.failure(error))
                            group.leave()
                            return
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(.success(()))
                }
            }
        }
    }
}
