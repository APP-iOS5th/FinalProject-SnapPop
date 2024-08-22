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
            try db.collection("Users")
                .document(AuthViewModel.shared.currentUser?.uid ?? "")
                .collection("Categories")
                .document(categoryId)
                .collection("Managements")
                .addDocument(from: management) { error in
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
    
    func loadManagements(categoryId: String, completion: @escaping (Result<[Management], Error>) -> Void) {
        db.collection("Users")
            .document(AuthViewModel.shared.currentUser?.uid ?? "")
            .collection("Categories")
            .document(categoryId)
            .collection("Managements")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                
                let managements = documents.compactMap { document in
                    try? document.data(as: Management.self)
                }
                
                completion(.success(managements))
            }
    }
    
    func updateManagement(categoryId: String, managementId: String, updatedManagement: Management, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("Users")
                .document(AuthViewModel.shared.currentUser?.uid ?? "")
                .collection("Categories")
                .document(categoryId)
                .collection("Managements")
                .document(managementId)
                .setData(from: updatedManagement, merge: true) { error in
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
    
    func deleteManagement(categoryId: String, managementId: String, completion: @escaping (Error?) -> Void) {
        db.collection("Users")
            .document(AuthViewModel.shared.currentUser?.uid ?? "")
            .collection("Categories")
            .document(categoryId)
            .collection("Managements")
            .document(managementId)
            .delete { error in
                if let error = error {
                    completion(error)
                }
            }
    }
    func markCompletion(categoryId: String, managementId: String, isCompletion: IsCompletion, completion: @escaping (Result<Void, Error>) -> Void) {
        let dateString = ISO8601DateFormatter().string(from: isCompletion.date)
        
        do {
            try db.collection("Users")
                .document(AuthViewModel.shared.currentUser?.uid ?? "")
                .collection("Categories")
                .document(categoryId)
                .collection("Managements")
                .document(managementId)
                .collection("Completion")
                .document(dateString)
                .setData(from: isCompletion, merge: true) { error in
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
    func getCompletion(categoryId: String, managementId: String, date: Date, completion: @escaping (Result<IsCompletion?, Error>) -> Void) {
        let dateString = ISO8601DateFormatter().string(from: date)
        
        db.collection("Users")
            .document(AuthViewModel.shared.currentUser?.uid ?? "")
            .collection("Categories")
            .document(categoryId)
            .collection("Managements")
            .document(managementId)
            .collection("Completion")
            .document(dateString)
            .getDocument { (documentSnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = documentSnapshot else {
                    completion(.failure(NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document snapshot is nil"])))
                    return
                }
                
                do {
                    let isCompletion = try document.data(as: IsCompletion.self)
                    completion(.success(isCompletion))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    func getMonthCompletions(categoryId: String, managementId: String, year: Int, month: Int, completion: @escaping (Result<[String: IsCompletion], Error>) -> Void) {
        let calendar = Calendar.current
        guard let startDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate) else {
            completion(.failure(NSError(domain: "DateError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid date components"])))
            return
        }
        
        let startDateString = ISO8601DateFormatter().string(from: startDate)
        let endDateString = ISO8601DateFormatter().string(from: endDate)
        
        db.collection("Users")
            .document(AuthViewModel.shared.currentUser?.uid ?? "")
            .collection("Categories")
            .document(categoryId)
            .collection("Managements")
            .document(managementId)
            .collection("Completion")
            .whereField(FieldPath.documentID(), isGreaterThanOrEqualTo: startDateString)
            .whereField(FieldPath.documentID(), isLessThanOrEqualTo: endDateString)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    completion(.failure(NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: "No documents found"])))
                    return
                }
                
                var completions: [String: IsCompletion] = [:]
                
                for document in documents {
                    do {
                        let isCompletion = try document.data(as: IsCompletion.self)
                        completions[document.documentID] = isCompletion
                    } catch {
                        print("Error decoding document \(document.documentID): \(error)")
                    }
                }
                
                completion(.success(completions))
            }
    }
}
    
    
    
