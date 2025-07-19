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
        
        // ── 1.  Pull the thread ID that iOS derived from   "aps.thread-id"
        let thread = response.notification.request.content.threadIdentifier
        if !thread.isEmpty {

            // ── 2.  Ask Notification Centre which banners are still showing
            let idsToRemove: [String] = await withCheckedContinuation { cont in
                center.getDeliveredNotifications { notes in
                    let ids = notes
                        .filter { $0.request.content.threadIdentifier == thread }
                        .map   { $0.request.identifier }
                    cont.resume(returning: ids)
                }
            }

            // ── 3.  Scrub them from the pull-down and from the lock-screen
            center.removeDeliveredNotifications(withIdentifiers: idsToRemove)

            // (optional) if you ever schedule *local* pushes for the
            // same chat, kill those too so they won’t pop up later
            center.removePendingNotificationRequests(withIdentifiers: idsToRemove)
        }
        
        
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
        print("The token has changed: \(token)")
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
