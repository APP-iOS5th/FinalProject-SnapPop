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
    let dateFormatter = DateFormatter()
    
    func saveManagement(categoryId: String, management: Management, completion: @escaping (Result<Management, Error>) -> Void) {
        let documentRef = db.collection("Users")
            .document(AuthViewModel.shared.currentUser?.uid ?? "")
            .collection("Categories")
            .document(categoryId)
            .collection("Managements")
            .document()
        
        var managementWithID = management
        managementWithID.id = documentRef.documentID
        
        do {
            try documentRef.setData(from: managementWithID) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(managementWithID))
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
    
    func updateCompletion(categoryId: String, managementId: String, date: Date, isCompleted: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        db.collection("Users")
            .document(AuthViewModel.shared.currentUser?.uid ?? "")
            .collection("Categories")
            .document(categoryId)
            .collection("Managements")
            .document(managementId)
            .updateData(["completions.\(dateString)": isCompleted ? 1 : 0]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    func deleteManagement(userId: String, categoryId: String, managementId: String, completion: @escaping (Error?) -> Void) {
        deleteDetailCosts(userId: userId, categoryId: categoryId, managementId: managementId) { result in
            switch result {
            case .success:
                self.db.collection("Users")
                    .document(userId)
                    .collection("Categories")
                    .document(categoryId)
                    .collection("Managements")
                    .document(managementId)
                    .delete { error in
                        if let error = error {
                            completion(error)
                        } else {
                            completion(nil)
                        }
                    }
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    // 관리들 모두 삭제
    func deleteManagements(userId: String, categoryId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentRef = db.collection("Users")
            .document(userId)
            .collection("Categories")
            .document(categoryId)
            .collection("Managements")
        
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
                    self.deleteDetailCosts(userId: userId, categoryId: categoryId, managementId: document.documentID) { result in
                        switch result {
                        case .success:
                            document.reference.delete { error in
                                if let error = error {
                                    completion(.failure(error))
                                    group.leave()
                                    return
                                }
                                group.leave()
                            }
                        case .failure(let error):
                            completion(.failure(error))
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    completion(.success(()))
                }
            }
        }
    }
    
    func addManagementException(categoryId: String, managementId: String, exceptionDate: Date, completion: @escaping (Result<Void, Error>) -> Void) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: exceptionDate)

        db.collection("Users")
            .document(AuthViewModel.shared.currentUser?.uid ?? "")
            .collection("Categories")
            .document(categoryId)
            .collection("Managements")
            .document(managementId)
            .updateData([
                "exceptionDates": FieldValue.arrayUnion([dateString])
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    func getManagementExceptions(categoryId: String, managementId: String, completion: @escaping (Result<[Date], Error>) -> Void) {
        db.collection("Users")
            .document(AuthViewModel.shared.currentUser?.uid ?? "")
            .collection("Categories")
            .document(categoryId)
            .collection("Managements")
            .document(managementId)
            .getDocument { (document, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = document, document.exists else {
                    completion(.failure(NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Management document not found"])))
                    return
                }
                
                let exceptionDates = document.data()?["exceptionDates"] as? [String] ?? []
                let dates = exceptionDates.compactMap { dateString -> Date? in
                    self.dateFormatter.date(from: dateString)
                }
                
                completion(.success(dates))
            }
    }
    
    func saveDetailCost(categoryId: String, managementId: String, detailCost: DetailCost, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("Users")
                .document(AuthViewModel.shared.currentUser?.uid ?? "")
                .collection("Categories")
                .document(categoryId)
                .collection("Managements")
                .document(managementId)
                .collection("DetailCosts")
                .addDocument(from: detailCost) { error in
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
    
    // 관리 하위의 상세 내역들 모두 삭제
    func deleteDetailCosts(userId: String, categoryId: String, managementId: String, completion: @escaping (Result<Void ,Error>) -> Void) {
        let documentRef = db.collection("Users")
            .document(userId)
            .collection("Categories")
            .document(categoryId)
            .collection("Managements")
            .document(managementId)
            .collection("DetailCosts")
        
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
                    document.reference.delete { error in
                        if let error = error {
                            completion(.failure(error))
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
