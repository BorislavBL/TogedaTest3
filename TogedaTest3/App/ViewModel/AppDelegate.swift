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

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure AWS Cognito
        let configuration = AWSServiceConfiguration(region: .EUCentral1, credentialsProvider: nil)

        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: "" ,
                                                                        clientSecret: "", poolId: "")
        AWSCognitoIdentityUserPool.register(with: configuration, userPoolConfiguration: poolConfiguration, forKey: "togeda-main")

        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        return true
    }
    

}

