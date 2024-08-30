//
//  DetailCostModel.swift
//  SnapPop
//
//  Created by 이인호 on 8/27/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

struct DetailCost: Identifiable, Hashable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String?
    var oneTimeCost: Int?
    var managementId: String?
}
