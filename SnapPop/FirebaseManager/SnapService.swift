//
//  SnapService.swift
//  SnapPop
//
//  Created by 이인호 on 8/13/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

final class SnapService {
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    func saveImage(data: Data, completion: @escaping (Result<String, Error>) -> Void)  {
        let path = UUID().uuidString
        let fileReference = storage.child(path)
        
        fileReference.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            fileReference.downloadURL { (url, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let downloadUrl = url?.absoluteString else { return }
                
                print(downloadUrl)
                completion(.success(downloadUrl))
            }
        }
    }
      
    func saveSnap(categoryId: String, imageUrls: [String], createdAt: Date, completion: @escaping (Result<Snap, Error>) -> Void) {
        let snap = Snap(imageUrls: imageUrls, createdAt: createdAt)
        
        do {
            try db.collection("Users")
                .document(AuthViewModel.shared.currentUser?.uid ?? "")
                .collection("Categories")
                .document(categoryId)
                .collection("Snaps")
                .addDocument(from: snap) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success((snap)))
                }
        } catch {
            completion(.failure(error))
        }
    }

    func loadSnap(categoryId: String, snapDate: Date, completion: @escaping (Result<Snap, Error>) -> Void) {
        // 날짜 equal 비교가 안되서 start <= snapDate < end 로 찾음
        let components = Calendar.current.dateComponents([.year, .month, .day], from: snapDate)
    
        guard let start = Calendar.current.date(from: components),
            let end = Calendar.current.date(byAdding: .day, value: 1, to: start)
        else {
            fatalError("Could not find start date or calculate end date.")
        }
        
        db.collection("Users")
            .document(AuthViewModel.shared.currentUser?.uid ?? "")
            .collection("Categories")
            .document(categoryId)
            .collection("Snaps")
            .whereField("createdAt", isGreaterThanOrEqualTo: start)
            .whereField("createdAt", isLessThan: end)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let document = querySnapshot?.documents.first else {
                    completion(.failure(NSError(domain: "NoDocumentError", code: -1, userInfo: nil)))
                    return
                }
                    
                do {
                    let snap = try document.data(as: Snap.self)
                    completion(.success(snap))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    func loadSnapsForMonth(categoryId: String, year: Int, month: Int, completion: @escaping (Result<[Snap], Error>) -> Void) {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: DateComponents(year: year, month: month)),
              let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            completion(.failure(NSError(domain: "InvalidDate", code: 0, userInfo: nil)))
            return
        }
        
        db.collection("Users")
            .document(AuthViewModel.shared.currentUser?.uid ?? "")
            .collection("Categories")
            .document(categoryId)
            .collection("Snaps")
            .whereField("createdAt", isGreaterThanOrEqualTo: startOfMonth)
            .whereField("createdAt", isLessThan: startOfNextMonth)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                
                let snaps = documents.compactMap { document in
                    try? document.data(as: Snap.self)
                }
                
                completion(.success(snaps))
            }
    }
    
    func loadSnaps(userId: String, categoryId: String, completion: @escaping (Result<[Snap], Error>) -> Void) {
        db.collection("Users")
            .document(userId)
            .collection("Categories")
            .document(categoryId)
            .collection("Snaps")
            .order(by: "createdAt", descending: false)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching documents: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                
                let snaps = documents.compactMap { document in
                    try? document.data(as: Snap.self)
                }
                
                completion(.success(snaps))
            }
    }
    
    func updateSnap(categoryId: String, snap: Snap, newImageUrls: [String], completion: @escaping (Result<Snap, Error>) -> Void) {
        if let snapId = snap.id {
            var updatedSnap = snap
            updatedSnap.imageUrls.append(contentsOf: newImageUrls)
//            var imageUrls = snap.imageUrls
//            imageUrls.append(contentsOf: newImageUrls)
            
            db.collection("Users")
                .document(AuthViewModel.shared.currentUser?.uid ?? "")
                .collection("Categories")
                .document(categoryId)
                .collection("Snaps")
                .document(snapId)
                .updateData(["imageUrls": updatedSnap.imageUrls]) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(updatedSnap))
                }
        }
    }
    
    // 회원 탈퇴 시 모든 데이터 삭제하는 부분에서 current user id 를 가져올수 없어 파라미터로 넣어서 전달하도록 수정
    func deleteImage(userId: String, categoryId: String, snap: Snap, imageUrlToDelete: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if let snapId = snap.id {
            var imageUrls = snap.imageUrls
            if let index = imageUrls.firstIndex(of: imageUrlToDelete) {
                imageUrls.remove(at: index)
            }
            
            db.collection("Users")
                .document(userId)
                .collection("Categories")
                .document(categoryId)
                .collection("Snaps")
                .document(snapId)
                .updateData(["imageUrls": imageUrls]) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    let imageRef = Storage.storage().reference(forURL: imageUrlToDelete)
                    imageRef.delete { error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        completion(.success(()))
                    }
                }
        }
    }
    
    func deleteSnap(userId: String, categoryId: String, snap: Snap, completion: @escaping (Error?) -> Void) {
        if let snapId = snap.id {
            db.collection("Users")
                .document(userId)
                .collection("Categories")
                .document(categoryId)
                .collection("Snaps")
                .document(snapId)
                .delete { error in
                    if let error = error {
                        completion(error)
                    } else {
                        completion(nil)
                    }
                }
        }
    }
    
    func deleteSnaps(userId: String, categoryId: String, completion: @escaping (Error?) -> Void) {
        
        loadSnaps(userId: userId, categoryId: categoryId) { result in
            switch result {
            case .success(let snaps):
                
                guard !snaps.isEmpty else {
                    completion(nil)// 스냅이 없는 경우 바로 카테고리 삭제
                    return
                }
                
                for snap in snaps {
                    for imageUrl in snap.imageUrls {
                        self.deleteImage(userId: userId, categoryId: categoryId, snap: snap, imageUrlToDelete: imageUrl) { result in
                            switch result {
                            case .success():
                                print("[SnapService] Success to deleteImage")
                            case .failure(let error):
                                print("[SnapService] Failed to deleteImage: \(error.localizedDescription)")
                            }
                        }
                    }
                    guard let snapId = snap.id else { return }
                    self.db.collection("Users")
                        .document(userId)
                        .collection("Categories")
                        .document(categoryId)
                        .collection("Snaps")
                        .document(snapId)
                        .delete { error in
                            if let error = error {
                                print("[SnapService] Failed to deleteSnap: \(error.localizedDescription)")
                            } else {
                                completion(nil)
                            }
                        }
                    
                }
            case .failure(let error):
                print("[SnapService] Failed to load snaps: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}
