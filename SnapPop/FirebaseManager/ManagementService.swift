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
        managementWithID.timeStamp = Timestamp(date: Date())
        
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
            .order(by: "timeStamp", descending: false)
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
                .setData(from: updatedManagement, merge: false) { error in
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
    // 오늘 이후의 것 삭제
    func deleteFutureCompletions(categoryId: String, managementId: String, from date: Date, completion: @escaping (Result<Void, Error>) -> Void) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        db.collection("Users")
            .document(AuthViewModel.shared.currentUser?.uid ?? "")
            .collection("Categories")
            .document(categoryId)
            .collection("Managements")
            .document(managementId)
            .getDocument { (documentSnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = documentSnapshot, document.exists, var management = try? document.data(as: Management.self) else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "관리 항목을 찾을 수 없습니다."])))
                    return
                }
                
                // 오늘 이후의 completions만 삭제 (오늘 포함)
                let filteredCompletions = management.completions.filter { key, _ in
                    return key < dateString
                }
                
                // Firestore에서 completions 업데이트
                self.db.collection("Users")
                    .document(AuthViewModel.shared.currentUser?.uid ?? "")
                    .collection("Categories")
                    .document(categoryId)
                    .collection("Managements")
                    .document(managementId)
                    .updateData(["completions": filteredCompletions]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
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
      
    func saveDetailCost(categoryId: String, managementId: String, detailCost: DetailCost, completion: @escaping (Result<Void, Error>) -> Void) {
        var updatedDetailCost = detailCost
        updatedDetailCost.managementId = managementId
        updatedDetailCost.timeStamp = Timestamp(date: Date())
        
        let documentRef = db.collection("Users")
            .document(AuthViewModel.shared.currentUser?.uid ?? "")
            .collection("Categories")
            .document(categoryId)
            .collection("Managements")
            .document(managementId)
            .collection("DetailCosts")
            .document()

        updatedDetailCost.id = documentRef.documentID

        do {
            try documentRef.setData(from: updatedDetailCost) { error in
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
    
    func loadDetailCosts(categoryId: String, managementId: String, completion: @escaping (Result<[DetailCost], Error>) -> Void) {
        db.collection("Users")
            .document(AuthViewModel.shared.currentUser?.uid ?? "")
            .collection("Categories")
            .document(categoryId)
            .collection("Managements")
            .document(managementId)
            .collection("DetailCosts")
            .order(by: "timeStamp", descending: false)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let detailCosts = documents.compactMap { document -> DetailCost? in
                    try? document.data(as: DetailCost.self)
                }
                
                completion(.success(detailCosts))
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
