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

extension Snap {
    // MARK: 임시 데이터 생성
    static func sampleData() -> [Snap] {
        let currentDate = Date() // 현재 날짜를 기준으로 생성
        
        return [
            Snap(id: "1", imageUrls: ["snaptest1"], createdAt: currentDate.addingTimeInterval(-86400)), // 1일 전
            Snap(id: "2", imageUrls: ["snaptest2"], createdAt: currentDate.addingTimeInterval(-172800)), // 2일 전
            Snap(id: "3", imageUrls: ["snaptest3"], createdAt: currentDate.addingTimeInterval(-259200)), // 3일 전
            Snap(id: "4", imageUrls: ["snaptest4"], createdAt: currentDate.addingTimeInterval(-345600))  // 4일 전
        ]
    }
}
