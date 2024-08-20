//
//  Category.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/19/24.
//
import Foundation
import FirebaseFirestore
import FirebaseStorage

struct Category: Identifiable, Hashable, Codable {
    @DocumentID var id: String?
    let userId: String
    var title: String
    var alertStatus: Bool
    
    init(userId: String, title: String, alertStatus: Bool) {
        self.userId = userId
        self.title = title
        self.alertStatus = alertStatus
    }
}
