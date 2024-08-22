//
//  Snap.swift
//  SnapPop
//
//  Created by Heeji Jung on 8/19/24.
//
import Foundation
import FirebaseFirestore
import FirebaseStorage

struct Snap: Identifiable, Hashable, Codable {
    @DocumentID var id: String?
    let imageUrls: [String]
    @ServerTimestamp var createdAt: Date?
    
    init(id: String?, imageUrls: [String], createdAt: Date?) {
        self.id = id
        self.imageUrls = imageUrls
        self.createdAt = createdAt
    }
}
