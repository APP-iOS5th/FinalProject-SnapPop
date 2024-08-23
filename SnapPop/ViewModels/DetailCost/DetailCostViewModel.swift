//
//  DetailCostViewModel.swift
//  SnapPop
//
//  Created by 장예진 on 8/23/24.
//

import Combine
import FirebaseFirestore

class DetailCostViewModel {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var cost: Double = 0.0
    @Published var additionalCosts: [Double] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let db = Firestore.firestore()
    private let documentID: String?
    
    init(documentID: String? = nil) {
        self.documentID = documentID
        
        if let documentID = documentID {
            loadData(for: documentID)
        }
    }
    
    private func loadData(for documentID: String) {
        // Firebase에서 데이터 로드
        db.collection("costDetails").document(documentID).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.title = data["title"] as? String ?? ""
                self.description = data["description"] as? String ?? ""
                self.cost = data["cost"] as? Double ?? 0.0
                self.additionalCosts = data["additionalCosts"] as? [Double] ?? []
            }
        }
    }

    func saveData(completion: @escaping () -> Void) {
        let costData: [String: Any] = [
            "title": title,
            "description": description,
            "cost": cost,
            "additionalCosts": additionalCosts
        ]
        
        if let documentID = documentID {
            // 기존 문서 업데이트
            db.collection("costDetails").document(documentID).setData(costData) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    completion()
                }
            }
        } else {
            // 새 문서를 추가하는 경우
            db.collection("costDetails").addDocument(data: costData) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    completion()
                }
            }
        }
    }
}
