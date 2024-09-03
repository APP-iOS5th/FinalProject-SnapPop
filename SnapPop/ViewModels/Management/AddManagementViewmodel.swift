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
    @Published var repeatCycle: Int = 0 
    @Published var alertTime: Date = Date()
    @Published var alertStatus: Bool = false
    
    @Published var detailCostArray: [DetailCost] = [] // 추가한 상세 비용들을 담을 배열
    
    var edit = false // 편집
    private var cancellables = Set<AnyCancellable>()
    var management: Management
    private let db = ManagementService()
    private let categoryService = CategoryService()

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
                guard let self = self else { return }
                self.management.startDate = newValue
                if self.edit {
                    self.updateCompletions()
                }
            }
            .store(in: &cancellables)
        
        $repeatCycle
            .removeDuplicates()
            .sink { [weak self] newValue in
                guard let self = self else { return }
                self.management.repeatCycle = newValue
                if self.edit {
                    self.updateCompletions()
                }
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
        
        loadDetailCosts(categoryId: categoryId, managementId: management.id)
    }
    
    func loadCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        categoryService.loadCategories { result in
            switch result {
            case .success(let categories):
                print("카테고리를 성공적으로 불러왔습니다: \(categories)")
                completion(.success(categories))
            case .failure(let error):
                print("카테고리 불러오기 실패: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    private func updateCompletions() {
        // 초기화
        self.management.completions.removeAll()
        // 새로운 completions 값 생성
        self.management.completions = generateSixMonthsCompletions(startDate: self.management.startDate, repeatInterval: self.management.repeatCycle)
    }
    
    func categoryDidChange(to newCategoryId: String?) {
        self.categoryId = newCategoryId
        print("Notification을 포스트합니다: categoryDidChangeNotification")
        NotificationCenter.default.post(name: .categoryDidChangeNotification, object: nil, userInfo: ["newCategoryId": newCategoryId ?? "default"])
    }
    
    func saveOrUpdate(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let categoryId = self.categoryId else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "카테고리 ID가 필요합니다."])))
            return
        }

        // 카테고리의 알림 상태 확인
        checkCategoryNotificationStatus(categoryId: categoryId) { isCategoryNotificationEnabled in
            if self.edit {
                // 편집 모드 - 관리 항목 업데이트
                guard let managementId = self.management.id else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "관리 항목 ID가 필요합니다."])))
                    return
                }
                self.db.updateManagement(categoryId: categoryId, managementId: managementId, updatedManagement: self.management) { result in
                    if case .success = result {
                        self.db.deleteDetailCosts(userId: AuthViewModel.shared.currentUser?.uid ?? "", categoryId: categoryId, managementId: managementId) { result in
                            switch result {
                            case .success:
                                for detailCost in self.detailCostArray {
                                    self.saveDetailCost(categoryId: self.categoryId, managementId: managementId, detailCost: detailCost)
                                }
                            case .failure(let error):
                                print("전체 상세 비용 삭제 실패: \(error.localizedDescription)")
                            }
                        }
                        
                        // 카테고리와 관리 항목의 알림 상태가 모두 true일 때만 알림을 추가
                        if isCategoryNotificationEnabled && self.management.alertStatus {
                            self.cancelNotification(for: self.management)
                            self.addNotification(for: self.management)
                        } else {
                            // 알림 상태가 false이거나 카테고리 알림이 꺼져 있으면 기존 알림 취소
                            self.cancelNotification(for: self.management)
                        }
                    }
                    completion(result)
                }
            } else {
                // 추가 모드 - 새로운 관리 항목 저장
                self.save { result in
                    if case .success = result {
                        // 카테고리와 관리 항목의 알림 상태가 모두 true일 때만 알림을 추가
                        if isCategoryNotificationEnabled && self.management.alertStatus {
                            self.addNotification(for: self.management)
                        }
                    }
                    completion(result)
                }
            }
        }
    }

    
    // 유효성 검증 프로퍼티
    var isValid: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest3($title, $color, $startDate)
            .map { title, color, startDate in
                return title.count >= 1 && color != .clear && startDate != nil
            }
            .eraseToAnyPublisher()
    }

    func save(completion: @escaping (Result<Void, Error>) -> Void) {
        // 유효성 검증
        guard title.count >= 1 else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "제목을 적어주세요."])))
            return
        }
        
        guard color != .clear else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "색상을 선택해주세요."])))
            return
        }
        
        guard startDate != nil else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "날짜를 선택해주세요."])))
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
                
                // 상세 비용 저장
                for detailCost in self.detailCostArray {
                    self.saveDetailCost(categoryId: self.categoryId, managementId: management.id, detailCost: detailCost)
                }

                completion(.success(()))
            case .failure(let error):
                print("Failed to save management: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
       
    private func cancelNotification(for management: Management) {
        guard let categoryId = self.categoryId, let managementId = management.id else { return }
        let identifiers = [
            "initialNotification-\(categoryId)-\(managementId)",
            "repeatingNotification-\(categoryId)-\(managementId)"
        ]
        NotificationManager.shared.removeNotification(identifiers: identifiers)
    }
    
    // 카테고리 알림 상태 확인 메서드 추가
    private func checkCategoryNotificationStatus(categoryId: String, completion: @escaping (Bool) -> Void) {
        categoryService.loadCategories { result in
            switch result {
            case .success(let categories):
                // 특정 categoryId를 가진 카테고리 검색
                if let category = categories.first(where: { $0.id == categoryId }) {
                    completion(category.alertStatus)
                } else {
                    print("카테고리를 찾을 수 없습니다.")
                    completion(false)
                }
            case .failure(let error):
                print("카테고리 로드 실패: \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    // 알림 추가 메서드 추가
    private func addNotification(for management: Management) {
        guard let categoryId = self.categoryId, let managementId = management.id else { return }
        
        if management.repeatCycle == 0 {
            // 한 번만 알림 추가
            NotificationManager.shared.initialNotification(categoryId: categoryId,
                                                           managementId: managementId,
                                                           startDate: management.startDate,
                                                           alertTime: management.alertTime,
                                                           repeatCycle: management.repeatCycle,
                                                           body: management.title)
        } else {
            if isSpecificDateInPast(startDate: self.startDate, alertTime: self.alertTime) {
                // 과거 날짜에 대한 반복 알림 추가
                NotificationManager.shared.repeatingNotification(categoryId: categoryId,
                                                                 managementId: managementId,
                                                                 startDate: management.startDate,
                                                                 alertTime: management.alertTime,
                                                                 repeatCycle: management.repeatCycle,
                                                                 body: management.title)
            } else {
                // 반복 알림을 트리거할 초기 알림 추가
                NotificationManager.shared.initialNotification(categoryId: categoryId,
                                                               managementId: managementId,
                                                               startDate: management.startDate,
                                                               alertTime: management.alertTime,
                                                               repeatCycle: management.repeatCycle,
                                                               body: management.title)
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
    
    func saveDetailCost(categoryId: String?, managementId: String?, detailCost: DetailCost) {
        if let categoryId = categoryId, let managementId = management.id {
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
    
    func loadDetailCosts(categoryId: String?, managementId: String?) {
        if let categoryId = categoryId, let managementId = management.id {
            db.loadDetailCosts(categoryId: categoryId, managementId: managementId) { result in
                switch result {
                case .success(let detailCosts):
                    self.detailCostArray = detailCosts
                case .failure(let error):
                    print("Failed to load detail costs: \(error.localizedDescription)")
                }
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
