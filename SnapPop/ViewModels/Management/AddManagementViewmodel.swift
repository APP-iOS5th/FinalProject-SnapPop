//
//  AddManagementViewmodel.swift
//  SnapPop
//
//  Created by 장예진 on 8/9/24.
//

import Combine
import UIKit

class AddManagementViewModel {
    @Published var title: String = ""
    @Published var memo: String = ""
    @Published var color: UIColor = .black
    @Published var createdAt: Date = Date()
    @Published var repeatCycle: Int = 0
    @Published var hasTimeAlert: Bool = false
    @Published var hasNotification: Bool = false
    @Published var isTimeCellExpanded: Bool = false

    let repeatOptions = ["매일", "매주", "매달", "안함"]

    private var cancellables = Set<AnyCancellable>()
    private var management: Management
    
    init(categoryId: String) {
        self.management = Management(
            categoryId: categoryId,
            title: "",
            color: "#000000",
            memo: "",
            repeatCycle: 0
        )
        
        bindManagementData()
    }

    private func bindManagementData() {
        $title
            .assign(to: \.management.title, on: self)
            .store(in: &cancellables)

        $memo
            .assign(to: \.management.memo, on: self)
            .store(in: &cancellables)

        $color
            .map { $0.toHexString() }
            .assign(to: \.management.color, on: self)
            .store(in: &cancellables)

        $createdAt
            .assign(to: \.management.createdAt, on: self)
            .store(in: &cancellables)

        $repeatCycle
            .assign(to: \.management.repeatCycle, on: self)
            .store(in: &cancellables)

        $hasTimeAlert
            .assign(to: \.management.hasTimeAlert, on: self)
            .store(in: &cancellables)

        $hasNotification
            .assign(to: \.management.hasNotification, on: self)
            .store(in: &cancellables)
    }

    func updateRepeatCycle(_ repeatCycle: Int) {
        self.repeatCycle = repeatCycle
    }

    func save(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
}

extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format: "#%06x", rgb)
    }
}
