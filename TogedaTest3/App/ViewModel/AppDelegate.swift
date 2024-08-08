//
//  AppDelegate.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 4.04.24.
//

import SwiftUI
import UIKit
import AWSCognitoIdentityProvider
import AWSCore
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate , ObservableObject{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure AWS Cognito

        
        return true
    }
    

    

}

extension AppDelegate {
    func requestNotificationPermissions(application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { granted, _ in
            guard granted else { return }

            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
}


extension AppDelegate{
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      let token = deviceToken.reduce("") { $0 + String(format: "%02x", $1) }
        APIClient.shared.notificationToken = token
//        if NotificationsManager.shared.authorizationStatus != .denied && NotificationsManager.shared.initialAuthorizationStatus == .notDetermined {
//            Task{
//                try await APIClient.shared.addDiviceToken()
//            }
//        } else if AuthClient.shared.userJustLoggedIn {
//            Task{
//                try await APIClient.shared.addDiviceToken()
//            }
//        } else {
//            print("Nooooo")
//        }
        
        if NotificationsManager.shared.authorizationStatus != .denied {
            Task{
                try await APIClient.shared.addDiviceToken()
            }
        }
        
        print(token)
    }


    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError
                     error: Error) {
        // Try again later.
        print("Fail to fetch divice token")
    }
    
//    // Handle notification when app is in foreground
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.sound, .badge, .banner])
//        
//        print("togeda listens 2")
////        handleNotification(notification: notification)
//    }
//
//    // Handle notification when app is in background or closed
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
////        handleNotification(notification: response.notification)
//        print("togeda listens 1")
//        completionHandler()
//    }
}

//to trigger
//appDelegate.requestNotificationPermissions(application: UIApplication.shared)
