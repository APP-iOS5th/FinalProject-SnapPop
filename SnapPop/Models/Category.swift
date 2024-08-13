//
//  Category.swift
//  SnapPop
//
//  Created by 이인호 on 8/12/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

struct Category: Identifiable, Hashable, Codable {
    @DocumentID var id: String?
    let userId: String
    let title: String
    
    init(userId: String, title: String) {
        self.userId = userId
        self.title = title
    }
}
