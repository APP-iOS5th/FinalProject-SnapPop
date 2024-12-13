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
        
        // Launch Screen을 항상 먼저
        showLaunchScreen()
        
        if let notificationResponse = connectionOptions.notificationResponse {
            let userInfo = notificationResponse.notification.request.content.userInfo
            if notificationResponse.notification.request.identifier.contains("dailySnapNotification") {
                // 추천 알림
                addRecommendNotificationData(userInfo: userInfo)
            } else {
                // 관리 알림
                addManagementNotificationData(userInfo: userInfo)
            }
            
        }
        
        // 로그인 상태 확인 및 온보딩 여부 확인
        let userDefaults = UserDefaults.standard
        
        if !userDefaults.bool(forKey: "onboardingCompleted") {
            // 온보딩 화면을 1초 후에 표시
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showOnboardingScreen()
            }
        } else {
            // 온보딩이 완료된 상태에서는 로그인 상태에 따라 화면 전환
            AuthViewModel.shared.listenAuthState { [weak self] _, user in
                guard let self = self else { return }
                
                let appLockState = UserDefaults.standard.bool(forKey: "appLockState")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if user != nil {
                        if appLockState {
                            LocalAuthenticationViewModel.execute { (success, error) in
                                if success {
                                    self.showMainScreen()
                                } else {
                                    
                                }
                            }
                        } else {
                            self.showMainScreen()
                        }
                    } else {
                        self.showSignInScreen()
                    }
                }
            }
        }
    }

    private func showOnboardingScreen() {
        let onboardingVC = OnboardingPageViewController()
        onboardingVC.onboardingDelegate = self
        window?.rootViewController = onboardingVC
        window?.makeKeyAndVisible()
    }
    
    private func showLaunchScreen() {
        // Launch Screen을 불러와서 표시
        let launchStoryboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        let launchScreenVC = launchStoryboard.instantiateInitialViewController()
        window?.rootViewController = launchScreenVC
        window?.makeKeyAndVisible()
    }

    private func showMainScreen() {
        // 메인 화면으로 전환
        DispatchQueue.main.async {
            self.window?.rootViewController = CustomTabBarController()
            self.window?.makeKeyAndVisible()
            self.requestNotificationAuthorization()
        }
    }

    private func showSignInScreen() {
        // 로그인 화면으로 전환
        DispatchQueue.main.async {
            self.window?.rootViewController = SignInViewController()
            self.window?.makeKeyAndVisible()
        }
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
        guard let body = userInfo["body"] as? String else { return }
        let alertTime = Date()
        
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
    
    
    // 화면 가리기 뷰 구성
    private func setupAppSwitcherMode() {
        guard let window = window else { return }
        appSwitcherModeImageView = UIImageView(frame: window.frame)
        appSwitcherModeImageView.image = UIImage(named: "launchScreen")
        appSwitcherModeImageView.contentMode = .scaleAspectFill
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
        if !notification.request.identifier.contains("initialNotification") {
            completionHandler([.banner, .list, .badge, .sound])
        } else {
            // 1. 반복 알림 등록에 쓰일 정보들을 단일 알림 userInfo에 저장해뒀다가 가져옴
            let userInfo = notification.request.content.userInfo
            
            guard let repeatCycle = userInfo["repeatCycle"] as? Int else {
                completionHandler([])
                return
            }
            
            if repeatCycle == 0 {
                completionHandler([.banner, .list, .badge, .sound])
            } else {
                // 특정 날짜로부터 시작하여 반복되는 관리 알림을 등록하기 위해 특정 날짜에 알림이 트리거되면 반복 알림을 등록한다
                guard let categoryId = userInfo["categoryId"] as? String,
                      let managementID = userInfo["managementId"] as? String,
                      let startDate = userInfo["startDate"] as? Date,
                      let alertTime = userInfo["alertTime"] as? Date,
                      let body = userInfo["body"] as? String else {
                    return
                }
                
                NotificationManager.shared.repeatingNotification(categoryId: categoryId, managementId: managementID, startDate: startDate,
                                                                 alertTime: alertTime, repeatCycle: repeatCycle, body: body)
                completionHandler([])
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.identifier.contains("dailySnapNotification")  {
            // 추천 알림
            
            let userInfo = response.notification.request.content.userInfo
            guard let body = userInfo["body"] as? String else { return }
            let alertTime = Date()
            
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
// 델리게이트 프로토콜 채택 및 넘어갈떄 애니메이션(페이드아웃)
extension SceneDelegate: OnboardingPageViewControllerDelegate {
    func didFinishOnboarding() {
        let loginVC = SignInViewController()
        loginVC.view.alpha = 0
        
        // 애니메이션 시작: 온보딩 화면에서 로그인 화면으로 전환
        UIView.transition(with: self.window!, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.window?.rootViewController = loginVC
        }) { _ in
            // 애니메이션 완료 후 로그인 화면의 뷰를 서서히 나타나게 함
            UIView.animate(withDuration: 0.2) {
                loginVC.view.alpha = 1
            }
            // 온보딩 완료 상태를 UserDefaults에 저장
            UserDefaults.standard.set(true, forKey: "onboardingCompleted")
            
            // 로그인 후 애니메이션이 끝난 후 메인 화면으로 전환
            AuthViewModel.shared.listenAuthState { [weak self] _, user in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if user != nil {
                        self.showMainScreen()
                    } else {
                        self.showSignInScreen()
                    }
                }
            }
        }
    }
}
