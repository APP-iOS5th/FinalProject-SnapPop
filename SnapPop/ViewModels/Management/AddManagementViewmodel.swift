//
//  AddManagementViewmodel.swift
//  SnapPop
//
//  Created by 장예진 on 8/9/24.
//

import Combine
import UIKit
import FirebaseFirestore

class AddManagementViewModel: CategoryChangeDelegate {
    
    var categoryId: String
    @Published var title: String = ""
    @Published var memo: String = ""
    @Published var color: UIColor = .black
    @Published var startDate: Date = Date()
    @Published var repeatCycle: Int = 0
    @Published var alertTime: Date = Date()
    @Published var alertStatus: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    var management: Management

    let repeatOptions = ["매일", "매주", "안함"]
    
    init(categoryId: String, management: Management) {
        self.categoryId = categoryId
        self.management = management
        
        // 기존 management 값으로 초기화
        self.title = management.title
        self.memo = management.memo
        self.color = UIColor(hexString: management.color) ?? .black
        self.startDate = management.startDate
        self.repeatCycle = management.repeatCycle
        self.alertTime = management.alertTime
        self.alertStatus = management.alertStatus
        
        bindManagementData()
    }
    
    convenience init(categoryId: String) {
        let defaultManagement = Management(
            title: "",
            memo: "",
            color: "#000000",
            startDate: Date(),
            repeatCycle: 0,
            alertTime: Date(),
            alertStatus: false,
            completions: [:]
        )
        self.init(categoryId: categoryId, management: defaultManagement)
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
                let repeatValue: Int
                switch newValue {
                case 0: // "매일"
                    repeatValue = 1
                case 1: // "매주"
                    repeatValue = 7
                case 2: // "안함"
                    repeatValue = 0
                default:
                    repeatValue = 0
                }
                self?.management.repeatCycle = repeatValue
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
    
    func categoryDidChange(to newCategoryId: String) {
        self.categoryId = newCategoryId
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
        
        let db = ManagementService()
        self.management.completions = generateSixMonthsCompletions(startDate: startDate, repeatInterval: management.repeatCycle)
//        print("Attempting to save management with data:")
//        print("Category ID: \(categoryId)")
//        print("Management ID: \(management.id ?? "nil")")
//        print("Title: \(management.title)")
//        print("Memo: \(management.memo)")
//        print("Color: \(management.color)")
//        print("Start Date: \(management.startDate)")
//        print("Repeat Cycle: \(management.repeatCycle)")
//        print("Alert Time: \(management.alertTime)")
//        print("Alert Status: \(management.alertStatus)")
//        print("Completions: \(management.completions)")

        db.saveManagement(categoryId: categoryId, management: management) { result in
            switch result {
            case .success(let management):
                print("Management saved successfully")
                
                if management.alertStatus {
                    if management.repeatCycle == 0 {
                        // 반복 안함으로 설정한 알림
                        NotificationManager.shared.initialNotification(managementId: management.id ?? "", startDate: management.startDate,
                                                                       alertTime: management.alertTime, repeatCycle: management.repeatCycle, body: management.title)
                    }
                    else {
                        if self.isSpecificDateInPast(startDate: self.startDate, alertTime: self.alertTime) {
                            // 만약 현재 시간보다 과거부터 시작하는 알림을 등록하면 초기 알림을 등록하여 반복 알림을 트리거 할 필요가 없으므로 바로 반복 알림을 등록해줌
                            NotificationManager.shared.repeatingNotification(managementId: management.id ?? "", startDate: management.startDate,
                                                                             alertTime: management.alertTime, repeatCycle: management.repeatCycle, body: management.title)
                        } else {
                            NotificationManager.shared.initialNotification(managementId: management.id ?? "", startDate: management.startDate,
                                                                           alertTime: management.alertTime, repeatCycle: management.repeatCycle, body: management.title)
                        }
                    }
                }
                
                completion(.success(()))
            case .failure(let error):
                print("Failed to save management: \(error.localizedDescription)")
                completion(.failure(error))
                
            }
        }
    }
    
    func generateSixMonthsCompletions(startDate: Date, repeatInterval: Int) -> [String: Int] {
            var completions: [String: Int] = [:]
            let calendar = Calendar.current
            let endDate = calendar.date(byAdding: .month, value: 6, to: startDate)!

            if repeatInterval == 0 {
                // 반복 주기가 0일 때는 시작일만 저장
                let dateString = ISO8601DateFormatter().string(from: startDate)
                completions[dateString] = 0
            } else {
                // 반복 주기가 0보다 클 때는 기존 로직 유지
                var currentDate = startDate
                while currentDate < endDate {
                    let dateString = ISO8601DateFormatter().string(from: currentDate)
                    completions[dateString] = 0 // 초기값은 미완료(0)로 설정
                    currentDate = calendar.date(byAdding: .day, value: repeatInterval, to: currentDate)!
                }
            }

            return completions
        }
    
    // 시작 날짜+시간이 현재보다 과거인지 아닌지를 확인하는 함수
    func isSpecificDateInPast(startDate: Date, alertTime: Date) -> Bool {
        let calendar = Calendar.current
        
        // startDate에서 year, month, day를 추출
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
        
        // alertTime에서 hour, minute를 추출
        dateComponents.hour = calendar.component(.hour, from: alertTime)
        dateComponents.minute = calendar.component(.minute, from: alertTime)
        
        if let specificDate = calendar.date(from: dateComponents) {
            return specificDate < Date()
        } else {
            return false
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
