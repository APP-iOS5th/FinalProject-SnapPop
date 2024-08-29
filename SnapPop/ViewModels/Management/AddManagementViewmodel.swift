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

    var categoryId: String?

    @Published var title: String = ""
    @Published var memo: String = ""
    @Published var color: UIColor = .black
    @Published var startDate: Date = Date()
    @Published var repeatCycle: Int = 2
    @Published var alertTime: Date = Date()
    @Published var alertStatus: Bool = false
    
    var edit = false // 편집
    private var cancellables = Set<AnyCancellable>()
    var management: Management
    var detailCostArray: [DetailCost] = [] // 추가한 상세 비용들을 담을 배열
    private let db = ManagementService()
    
    let repeatOptions = ["매일", "매주", "안함"]
    
    init(categoryId: String?, management: Management) {
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
    
    convenience init(categoryId: String?) {
        let defaultManagement = Management(
            title: "",
            memo: "",
            color: "#000000",
            startDate: Date(),
            repeatCycle: 2,
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
        
        let repeatValue: Int
        switch cycleIndex {
        case 0: // "매일"
            repeatValue = 1
        case 1: // "매주"
            repeatValue = 7
        case 2: // "안함"
            repeatValue = 0
        default:
            repeatValue = 0
        }
        self.management.repeatCycle = repeatValue
    }
    
    func categoryDidChange(to newCategoryId: String?) {
        self.categoryId = newCategoryId
        print("Notification을 포스트합니다: categoryDidChangeNotification")
        NotificationCenter.default.post(name: .categoryDidChangeNotification, object: nil, userInfo: ["newCategoryId": newCategoryId ?? "default"])
    }
    
    func saveOrUpdate(completion: @escaping (Result<Void, Error>) -> Void) {
        if edit {
            // 편집 모드 - 관리 항목 업데이트
            guard let categoryId = categoryId, let managementId = management.id else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "카테고리 ID 또는 관리 항목 ID가 필요합니다."])))
                return
            }
            db.updateManagement(categoryId: categoryId, managementId: managementId, updatedManagement: management, completion: completion)
        } else {
            // 추가 모드 - 새로운 관리 항목 저장(맞네이렇게해야되네)
            save(completion: completion)
        }
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
        
        self.management.completions = generateSixMonthsCompletions(startDate: startDate, repeatInterval: management.repeatCycle)
        
        // Firebase에 관리 항목 저장
        db.saveManagement(categoryId: categoryId ?? "", management: management) { result in
            switch result {
            case .success(let management):
                print("Management saved successfully")
                
                self.management = management
            
                NotificationCenter.default.post(name: .managementSavedNotification, object: nil)
                guard let categoryId = self.categoryId else { return }
                
                // 상세 비용 저장
                for detailCost in self.detailCostArray {
                    self.saveDetailCost(categoryId: categoryId, managementId: management.id ?? "", detailCost: detailCost)
                }
                
                // 알림 설정
                if management.alertStatus {
                    if management.repeatCycle == 0 {
                        NotificationManager.shared.initialNotification(managementId: management.id ?? "", startDate: management.startDate,
                                                                       alertTime: management.alertTime, repeatCycle: management.repeatCycle, body: management.title)
                    } else {
                        if self.isSpecificDateInPast(startDate: self.startDate, alertTime: self.alertTime) {
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if repeatInterval == 0 {
            // 반복 주기가 0일 때는 시작일만 저장
            let dateString = dateFormatter.string(from: startDate)
            completions[dateString] = 0
        } else {
            // 반복 주기가 0보다 클 때는 기존 로직 유지
            var currentDate = startDate
            while currentDate < endDate {
                let dateString = dateFormatter.string(from: currentDate)
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
    
    func saveDetailCost(categoryId: String, managementId: String, detailCost: DetailCost) {
        db.saveDetailCost(categoryId: categoryId, managementId: managementId, detailCost: detailCost) { result in
            switch result {
            case .success:
                print("상세 비용 저장 성공")
            case .failure(let error):
                print("상세 비용 저장 실패: \(error.localizedDescription)")
            }
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

extension Notification.Name {
    static let categoryDidChangeNotification = Notification.Name("categoryDidChangeNotification")
    static let managementSavedNotification = Notification.Name("managementSavedNotification")
}
