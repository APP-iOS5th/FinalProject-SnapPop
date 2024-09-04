//
//  SceneDelegate.swift
//  SnapPop
//
//  Created by 김형준 on 8/7/24.
//

import UIKit
import UserNotifications

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appSwitcherModeImageView = UIImageView()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .systemBackground
        
        if let notificationResponse = connectionOptions.notificationResponse {
            let userInfo = notificationResponse.notification.request.content.userInfo
            if !notificationResponse.notification.request.identifier.contains("initialNotification") {
                // 추천 알림
                addRecommendNotificationData(userInfo: userInfo)
            } else {
                // 관리 알림
                addManagementNotificationData(userInfo: userInfo)
            }
            
        }
        
        AuthViewModel.shared.listenAuthState { _, user in
            let appLockState = UserDefaults.standard.bool(forKey: "appLockState")
            
            if user != nil {
                if appLockState {
                    LocalAuthenticationViewModel.execute { (success, error) in
                        DispatchQueue.main.async {
                            if success {
                                self.window?.rootViewController = CustomTabBarController()
                            } else {
                                // 잠금 인증 실패
                            }
                            self.window?.makeKeyAndVisible()
                            self.requestNotificationAuthorization()
                        }
                    }
                } else {
                    self.window?.rootViewController = CustomTabBarController()
                    self.window?.makeKeyAndVisible()
                    self.requestNotificationAuthorization()
                }
            } else {
                self.window?.rootViewController = SignInViewController()
                self.window?.makeKeyAndVisible()
            }
        }
//        // 실제 폰트랑 폰트네임이 달라서 family name 찍어보고 확인하여 호출
//        UIFont.familyNames.sorted().forEach { familyName in
//            print("*** \(familyName) ***")
//            UIFont.fontNames(forFamilyName: familyName).forEach { fontName in
//                print("\(fontName)")
//            }
//            print("---------------------")
//        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        appSwitcherModeImageView.removeFromSuperview()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        let appLockState = UserDefaults.standard.bool(forKey: "appLockState")
        
        if appLockState {
            // 앱 잠금 상태일 때만 보호 화면 추가
            setupAppSwitcherMode()
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    // 추천 알림 데이터를 UserDefaults에 저장하는 메서드
    func addRecommendNotificationData(userInfo: [AnyHashable: Any]) {
        guard let alertTime = userInfo["alertTime"] as? Date,
              let body = userInfo["body"] as? String else {
            return
        }
        
        let notificationData = NotificationData(categoryId: nil, managementId: nil, title: body, date: alertTime)
        
        var savedNotifications = UserDefaults.standard.array(forKey: "savedRecommendNotifications") as? [Data] ?? []
        if !savedNotifications.contains(where: {
            guard let decodedData = try? JSONDecoder().decode(NotificationData.self, from: $0) else {
                return false
            }
            return decodedData.title == notificationData.title && decodedData.date == notificationData.date
        }) {
            if let encoded = try? JSONEncoder().encode(notificationData) {
                savedNotifications.append(encoded)
                UserDefaults.standard.set(savedNotifications, forKey: "savedRecommendNotifications")
            }
            
            NotificationCenter.default.post(name: .newRecommendNotificationReceived, object: nil)
        }
    }
    
    // 관리 알림 데이터를 UserDefaults에 저장하는 메서드
    func addManagementNotificationData(userInfo: [AnyHashable: Any]) {
        guard let repeatCycle = userInfo["repeatCycle"] as? Int else {
            return
        }
        
        if repeatCycle == 0 {
            guard let categoryId = userInfo["categoryId"] as? String,
                  let managementID = userInfo["managementId"] as? String,
                  let alertTime = userInfo["alertTime"] as? Date,
                  let body = userInfo["body"] as? String else {
                return
            }
            
            let notificationData = NotificationData(categoryId: categoryId, managementId: managementID, title: body, date: alertTime)
            
            var savedNotifications = UserDefaults.standard.array(forKey: "savedNotifications") as? [Data] ?? []
            // 중복 확인
            if !savedNotifications.contains(where: {
                guard let decodedData = try? JSONDecoder().decode(NotificationData.self, from: $0) else {
                    return false
                }
                return decodedData.categoryId == notificationData.categoryId &&
                decodedData.managementId == notificationData.managementId &&
                decodedData.date == notificationData.date
            }) {
                if let encoded = try? JSONEncoder().encode(notificationData) {
                    savedNotifications.append(encoded)
                    UserDefaults.standard.set(savedNotifications, forKey: "savedNotifications")
                }
                
                NotificationCenter.default.post(name: .newNotificationReceived, object: nil)
            }
            
            NotificationCenter.default.post(name: .newNotificationReceived, object: nil)
            
        } else {
            // 특정 날짜로부터 시작하여 반복되는 관리 알림을 등록하기 위해 특정 날짜에 알림이 트리거되면 반복 알림을 등록한다
            guard let categoryId = userInfo["categoryId"] as? String,
                  let managementID = userInfo["managementId"] as? String,
                  let startDate = userInfo["startDate"] as? Date,
                  let alertTime = userInfo["alertTime"] as? Date,
                  let body = userInfo["body"] as? String else {
                return
            }
            
            NotificationManager.shared.repeatingNotification(categoryId: categoryId,
                                                             managementId: managementID,
                                                             startDate: startDate,
                                                             alertTime: alertTime,
                                                             repeatCycle: repeatCycle,
                                                             body: body)
            
            let notificationData = NotificationData(categoryId: categoryId, managementId: managementID, title: body, date: alertTime)
            
            var savedNotifications = UserDefaults.standard.array(forKey: "savedNotifications") as? [Data] ?? []
            
            // 중복 확인
            if !savedNotifications.contains(where: {
                guard let decodedData = try? JSONDecoder().decode(NotificationData.self, from: $0) else {
                    return false
                }
                return decodedData.categoryId == notificationData.categoryId &&
                decodedData.managementId == notificationData.managementId &&
                decodedData.date == notificationData.date
            }) {
                if let encoded = try? JSONEncoder().encode(notificationData) {
                    savedNotifications.append(encoded)
                    UserDefaults.standard.set(savedNotifications, forKey: "savedNotifications")
                }
                
                NotificationCenter.default.post(name: .newNotificationReceived, object: nil)
            }
        }
    } // addManagementNotificationData
    
    
    // 화면 가리기 뷰 구성 (임시)
    private func setupAppSwitcherMode() {
        guard let window = window else { return }
        appSwitcherModeImageView = UIImageView(frame: window.frame)
        appSwitcherModeImageView.image = UIImage(named: "AppIcon")?.resized(to: CGSize(width: 100, height: 100))
        appSwitcherModeImageView.contentMode = .center
        appSwitcherModeImageView.backgroundColor = UIColor(named: "Iconbackground")
        window.addSubview(appSwitcherModeImageView)
    }
}

extension SceneDelegate: UNUserNotificationCenterDelegate {
    func requestNotificationAuthorization() {
        // MARK: - UNUserNotificationCenterDelegate
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification authorization granted")
            } else {
                print("Notification authorization denied")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if !response.notification.request.identifier.contains("initialNotification") || response.notification.request.identifier.contains("dailySnapNotification")  {
            // 추천 알림
            
            let userInfo = response.notification.request.content.userInfo
            guard let alertTime = userInfo["alertTime"] as? Date,
                  let body = userInfo["body"] as? String else { return }
            
            let notificationData = NotificationData(categoryId: nil,
                                                    managementId: nil,
                                                    title: body,
                                                    date: alertTime)
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // 알림을 클릭했을 때
                print("User tapped on the notification")

                var savedNotifications = UserDefaults.standard.array(forKey: "savedRecommendNotifications") as? [Data] ?? []
                if let encoded = try? JSONEncoder().encode(notificationData) {
                    savedNotifications.append(encoded)
                    UserDefaults.standard.set(savedNotifications, forKey: "savedRecommendNotifications")
                }
                
                NotificationCenter.default.post(name: .newRecommendNotificationReceived, object: nil)
            case UNNotificationDismissActionIdentifier:
                // 알림을 닫았을 때
                var savedNotifications = UserDefaults.standard.array(forKey: "savedRecommendNotifications") as? [Data] ?? []
                if let encoded = try? JSONEncoder().encode(notificationData) {
                    savedNotifications.append(encoded)
                    UserDefaults.standard.set(savedNotifications, forKey: "savedRecommendNotifications")
                }
                
                NotificationCenter.default.post(name: .newNotificationReceived, object: nil)
            default:
                var savedNotifications = UserDefaults.standard.array(forKey: "savedRecommendNotifications") as? [Data] ?? []
                if let encoded = try? JSONEncoder().encode(notificationData) {
                    savedNotifications.append(encoded)
                    UserDefaults.standard.set(savedNotifications, forKey: "savedRecommendNotifications")
                }
                
                NotificationCenter.default.post(name: .newRecommendNotificationReceived, object: nil)
                break
            }
            
            var savedNotifications = UserDefaults.standard.array(forKey: "savedRecommendNotifications") as? [Data] ?? []
            // 중복 확인
            if !savedNotifications.contains(where: {
                guard let decodedData = try? JSONDecoder().decode(NotificationData.self, from: $0) else {
                    return false
                }
                return decodedData.categoryId == notificationData.categoryId &&
                decodedData.managementId == notificationData.managementId &&
                decodedData.date == notificationData.date
            }) {
                if let encoded = try? JSONEncoder().encode(notificationData) {
                    savedNotifications.append(encoded)
                    UserDefaults.standard.set(savedNotifications, forKey: "savedRecommendNotifications")
                }
                
                NotificationCenter.default.post(name: .newNotificationReceived, object: nil)
            }
            
            NotificationCenter.default.post(name: .newNotificationReceived, object: nil)
            
            completionHandler()
        } else {
            // 관리 알림
            
            let userInfo = response.notification.request.content.userInfo
            guard let categoryId = userInfo["categoryId"] as? String,
                  let managementID = userInfo["managementId"] as? String,
                  let alertTime = userInfo["alertTime"] as? Date,
                  let body = userInfo["body"] as? String else { return }
            
            let notificationData = NotificationData(categoryId: categoryId, managementId: managementID, title: body, date: alertTime)
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // 알림을 클릭했을 때
                print("User tapped on the notification")

                var savedNotifications = UserDefaults.standard.array(forKey: "savedNotifications") as? [Data] ?? []
                if let encoded = try? JSONEncoder().encode(notificationData) {
                    savedNotifications.append(encoded)
                    UserDefaults.standard.set(savedNotifications, forKey: "savedNotifications")
                }
                
                NotificationCenter.default.post(name: .newNotificationReceived, object: nil)
            case UNNotificationDismissActionIdentifier:
                // 알림을 닫았을 때
                var savedNotifications = UserDefaults.standard.array(forKey: "savedNotifications") as? [Data] ?? []
                if let encoded = try? JSONEncoder().encode(notificationData) {
                    savedNotifications.append(encoded)
                    UserDefaults.standard.set(savedNotifications, forKey: "savedNotifications")
                }
                
                NotificationCenter.default.post(name: .newNotificationReceived, object: nil)
            default:
                var savedNotifications = UserDefaults.standard.array(forKey: "savedNotifications") as? [Data] ?? []
                if let encoded = try? JSONEncoder().encode(notificationData) {
                    savedNotifications.append(encoded)
                    UserDefaults.standard.set(savedNotifications, forKey: "savedNotifications")
                }
                
                NotificationCenter.default.post(name: .newNotificationReceived, object: nil)
                break
            }
            
            var savedNotifications = UserDefaults.standard.array(forKey: "savedNotifications") as? [Data] ?? []
            // 중복 확인
            if !savedNotifications.contains(where: {
                guard let decodedData = try? JSONDecoder().decode(NotificationData.self, from: $0) else {
                    return false
                }
                return decodedData.categoryId == notificationData.categoryId &&
                decodedData.managementId == notificationData.managementId &&
                decodedData.date == notificationData.date
            }) {
                if let encoded = try? JSONEncoder().encode(notificationData) {
                    savedNotifications.append(encoded)
                    UserDefaults.standard.set(savedNotifications, forKey: "savedNotifications")
                }
                
                NotificationCenter.default.post(name: .newNotificationReceived, object: nil)
            }
            
            NotificationCenter.default.post(name: .newNotificationReceived, object: nil)
            
            completionHandler()
        }
        
        
    }
}
