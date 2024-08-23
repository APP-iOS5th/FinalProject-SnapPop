//
//  AddManagementViewmodel.swift
//  SnapPop
//
//  Created by 장예진 on 8/9/24.
//

import Combine
import UIKit
import FirebaseFirestore

class AddManagementViewModel {
    let categoryId: String
    @Published var title: String = ""
    @Published var memo: String = ""
    @Published var color: UIColor = .black
    @Published var startDate: Date = Date()
    @Published var repeatCycle: Int = 0
    @Published var alertTime: Date = Date()
    @Published var alertStatus: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private var management: Management
    
    let repeatOptions = ["매일", "매주", "안함"]

    init(categoryId: String) {
        self.categoryId = categoryId
        self.management = Management(
            title: "",
            memo: "",
            color: "#000000",
            startDate: Date(),
            repeatCycle: 0,
            alertTime: Date(),
            alertStatus: false
        )
        bindManagementData()
    }

    private func bindManagementData() {
        $title
            .sink { [weak self] newValue in
                self?.management.title = newValue
            }
            .store(in: &cancellables)

        $memo
            .sink { [weak self] newValue in
                self?.management.memo = newValue
            }
            .store(in: &cancellables)

        $color
            .map { $0.toHexString() }
            .sink { [weak self] newValue in
                self?.management.color = newValue
            }
            .store(in: &cancellables)

        $startDate
            .sink { [weak self] newValue in
                self?.management.startDate = newValue
            }
            .store(in: &cancellables)

        $repeatCycle
            .sink { [weak self] newValue in
                self?.management.repeatCycle = newValue
            }
            .store(in: &cancellables)

        $alertTime
            .sink { [weak self] newValue in
                self?.management.alertTime = newValue
            }
            .store(in: &cancellables)

        $alertStatus
            .sink { [weak self] newValue in
                self?.management.alertStatus = newValue
            }
            .store(in: &cancellables)
    }
    
    func updateRepeatCycle(_ cycleIndex: Int) {
        self.repeatCycle = cycleIndex
    }

    // 유효성 검증 프로퍼티
    var isValid: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest3($title, $color, $startDate)
            .map { title, color, startDate in
                return title.count >= 2 && color != .clear && startDate != nil
            }
            .eraseToAnyPublisher()
    }

    func save(completion: @escaping (Result<Void, Error>) -> Void) {
        // 유효성 검증
        guard title.count >= 2 else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "제목은 2자 이상이어야 합니다."])))
            return
        }
        
        guard color != .clear else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "색상을 선택해야 합니다."])))
            return
        }

        guard startDate != nil else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "날짜를 선택해야 합니다."])))
            return
        }

        let db = Firestore.firestore()
        do {
            if let id = management.id {
                try db.collection("management").document(id).setData(from: management)
            } else {
                let _ = try db.collection("management").addDocument(from: management)
            }
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}

extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        
        return String(format: "#%06x", rgb)
    }
    
    convenience init?(hexString: String) {
        var hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if hex.count == 6 {
            hex.append("FF")
        }

        guard hex.count == 8 else { return nil }

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r = CGFloat((int >> 24) & 0xFF) / 255.0
        let g = CGFloat((int >> 16) & 0xFF) / 255.0
        let b = CGFloat((int >> 8) & 0xFF) / 255.0
        let a = CGFloat(int & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

