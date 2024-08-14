//
//  Snap.swift
//  SnapPop
//
//  Created by 이인호 on 8/13/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

struct Snap: Identifiable, Hashable, Codable {
    @DocumentID var id: String?
    let imageUrls: [String]
    @ServerTimestamp var createdAt: Date?
    
    init(imageUrls: [String]) {
        self.imageUrls = imageUrls
        self.createdAt = Date()
    }

}
