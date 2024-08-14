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
    
    func saveCategory(category: Category, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("Users")
                .document(AuthViewModel.shared.currentUser?.uid ?? "")
                .collection("Categories")
                .addDocument(from: category) { error in
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
    
    func loadCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        db.collection("Users")
            .document(AuthViewModel.shared.currentUser?.uid ?? "")
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
    
    func deleteCategory(categoryId: String, completion: @escaping (Error?) -> Void) {
        db.collection("Users")
            .document(AuthViewModel.shared.currentUser?.uid ?? "")
            .collection("Categories")
            .document(categoryId)
            .delete { error in
                if let error = error {
                    completion(error) // firestore에서 없는 문서를 삭제하려고 해도 에러를 반환하지 않도록 설계되어있음
                }
            }
    }
}
