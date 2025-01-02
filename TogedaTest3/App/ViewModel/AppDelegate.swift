//
//  AppDelegate.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 4.04.24.
//

import SwiftUI
import UIKit
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject{
    
    @Published var urlHandler: URLHandler?
    @Published var deeplink: URL?
    @Published var appSetupDone: Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure AWS Cognito
//        let configuration = AWSServiceConfiguration(region: .EUCentral1, credentialsProvider: nil)
//        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: "",
//                                                                        clientSecret: "", poolId: "")
//        AWSCognitoIdentityUserPool.register(with: configuration, userPoolConfiguration: poolConfiguration, forKey: "")
//
//        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
//        requestNotificationPermissions(application: application)
        
        UNUserNotificationCenter.current().delegate = self
        
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


extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print("This one is also activated")
        if let deepLink = response.notification.request.content.userInfo["link"] as? String {
            print("\(deepLink)")
            if let url = URL(string: deepLink) {
                print("This one is also activated Also")

                
                if appSetupDone {
                    print("Numbero 1")
                    Task{
                        urlHandler?.handleURL(_: url)
                    }
                } else {
                    print("Numbero 2")
                    DispatchQueue.main.async {
                        self.deeplink = url
                    }
                }
                
            }
        }
        
        print("Not userInfo: \(response.notification.request.content.userInfo)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.sound, .banner, .badge, .list]
    }
    
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
        
        print("Token Print:", token)
    }


    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError
                     error: Error) {
        // Try again later.
        print("Fail to fetch divice token")
    }
    
//    // Handle notification when app is in background or closed
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
////        handleNotification(notification: response.notification)
//        print("togeda listens 1")
//        completionHandler()
//    }
}

//to trigger
//appDelegate.requestNotificationPermissions(application: UIApplication.shared)
