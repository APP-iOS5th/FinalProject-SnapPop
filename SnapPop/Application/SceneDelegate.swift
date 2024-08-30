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
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .systemBackground
        
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
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
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
            let userInfo = notification.request.content.userInfo
            
            guard let repeatCycle = userInfo["repeatCycle"] as? Int else {
                completionHandler([])
                return
            }
            
            if repeatCycle == 0 {
                guard let categoryId = userInfo["categoryId"] as? String,
                      let managementID = userInfo["managementId"] as? String,
                      let startDate = userInfo["startDate"] as? Date,
                      let alertTime = userInfo["alertTime"] as? Date,
                      let body = userInfo["body"] as? String else {
                    completionHandler([])
                    return
                }
                
                let notificationData = NotificationData(categoryId: categoryId, managementId: managementID, title: body, date: alertTime)
                
                var savedNotifications = UserDefaults.standard.array(forKey: "savedNotifications") as? [Data] ?? []
                if let encoded = try? JSONEncoder().encode(notificationData) {
                    savedNotifications.append(encoded)
                    UserDefaults.standard.set(savedNotifications, forKey: "savedNotifications")
                }
                
                NotificationCenter.default.post(name: .newNotificationReceived, object: nil)
                
                
                completionHandler([.banner, .list, .badge, .sound])
            } else {
                // 특정 날짜로부터 시작하여 반복되는 관리 알림을 등록하기 위해 특정 날짜에 알림이 트리거되면 반복 알림을 등록한다
                guard let categoryId = userInfo["categoryId"] as? String,
                      let managementID = userInfo["managementId"] as? String,
                      let startDate = userInfo["startDate"] as? Date,
                      let alertTime = userInfo["alertTime"] as? Date,
                      let body = userInfo["body"] as? String else {
                    completionHandler([])
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
                if let encoded = try? JSONEncoder().encode(notificationData) {
                    savedNotifications.append(encoded)
                    UserDefaults.standard.set(savedNotifications, forKey: "savedNotifications")
                }
                
                NotificationCenter.default.post(name: .newNotificationReceived, object: nil)
                
                completionHandler([])
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        guard let categoryId = userInfo["categoryId"] as? String,
              let managementID = userInfo["managementId"] as? String,
              let startDate = userInfo["startDate"] as? Date,
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
        if let encoded = try? JSONEncoder().encode(notificationData) {
            savedNotifications.append(encoded)
            UserDefaults.standard.set(savedNotifications, forKey: "savedNotifications")
        }
        
        NotificationCenter.default.post(name: .newNotificationReceived, object: nil)
        
        completionHandler()
    }
}
