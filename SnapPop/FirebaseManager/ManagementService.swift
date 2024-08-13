//
//  ManagementService.swift
//  SnapPop
//
//  Created by 이인호 on 8/12/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

final class ManagementService {
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    func saveManagement(categoryId: String, management: Management, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("Categories")
                .document(categoryId)
                .collection("Managements")
                .addDocument(from: management) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }
    
    func loadManagements(categoryId: String, completion: @escaping (Result<[Management], Error>) -> Void) {
        db.collection("Categories")
            .document(categoryId)
            .collection("Managements")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    guard let documents = querySnapshot?.documents else { return }
                    
                    let managements = documents.compactMap { document in
                        try? document.data(as: Management.self)
                    }
                    
                    completion(.success(managements))
                }
            }
    }
    
    func updateManagement(categoryId: String, managementId: String, updatedManagement: Management, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("Categories")
                .document(categoryId)
                .collection("Managements")
                .document(managementId)
                .setData(from: updatedManagement, merge: true) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteManagement(categoryId: String, managementId: String, completion: @escaping (Error?) -> Void) {
        db.collection("Categories")
            .document(categoryId)
            .collection("Managements")
            .document(managementId)
            .delete { error in
                if let error = error {
                    completion(error)
                }
            }
    }
}
