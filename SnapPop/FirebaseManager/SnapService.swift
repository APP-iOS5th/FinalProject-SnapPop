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
      
    func saveSnap(categoryId: String, imageUrls: [String], completion: @escaping (Result<Snap, Error>) -> Void) {
        let snap = Snap(imageUrls: imageUrls, createdAt: Date())
        
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
    
    func loadSnaps(categoryId: String, completion: @escaping (Result<[Snap], Error>) -> Void) {
        db.collection("Users")
            .document(AuthViewModel.shared.currentUser?.uid ?? "")
            .collection("Categories")
            .document(categoryId)
            .collection("Snaps")
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
    
    func deleteImage(categoryId: String, snap: Snap, imageUrlToDelete: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if let snapId = snap.id {
            var imageUrls = snap.imageUrls
            if let index = imageUrls.firstIndex(of: imageUrlToDelete) {
                imageUrls.remove(at: index)
            }
            
            db.collection("Users")
                .document(AuthViewModel.shared.currentUser?.uid ?? "")
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
    
    func deleteSnap(categoryId: String, snap: Snap, completion: @escaping (Error?) -> Void) {
        if let snapId = snap.id {
            db.collection("Users")
                .document(AuthViewModel.shared.currentUser?.uid ?? "")
                .collection("Categories")
                .document(categoryId)
                .collection("Snaps")
                .document(snapId)
                .delete { error in
                    if let error = error {
                        completion(error)
                    }
                }
        }
    }
}
