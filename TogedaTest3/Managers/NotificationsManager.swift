//
//  NotificationsManager.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 19.06.24.
//

import UIKit
import UserNotifications

class NotificationsManager: ObservableObject {
    static let shared = NotificationsManager()
    let center = UNUserNotificationCenter.current()
    @Published var authorizationStatus: UNAuthorizationStatus?
    @Published var initialAuthorizationStatus: UNAuthorizationStatus?
    
    func setupAuthStatus() {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
                self.initialAuthorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { allowed, error in
            if allowed {
                // register for remote push notification
                self.getNotificationSettings()
            } else {
                print("Error while requesting push notification permission. Error \(error)")
            }
        }
    }

    func getNotificationSettings() {
        center.getNotificationSettings { settings in
            if settings.authorizationStatus != .denied {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    self.authorizationStatus = settings.authorizationStatus
                }
            }

        }

    }

}
