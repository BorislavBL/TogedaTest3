//
//  ContentViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation
import SwiftUI

enum AuthenticationState {
    case checking
    case authenticatedNoInformation
    case authenticated
    case unauthenticated
    case update
}

class ContentViewModel: ObservableObject {
    @Published var resetCurrentUser = false
    @Published var authenticationState: AuthenticationState = .checking
    private var tokenCheckTimer: Timer?
//    @Published var mainAccessToken: String?
    @Published var pendingURL: URL?
    @Published var sessionCount = 0
    @State var appVersion: String?
    @State var buildNumber: String?
    
    init(){
        Task{
//            await validateTokensAndCheckState()
            do{
                try await generalCheck()
            } catch{
                print(error)
            }
        }
    }
    
    deinit {
        print("De init triggerd")
        tokenCheckTimer?.invalidate()
    }
    
    
    func logout(){
        Task{
            AuthService.shared.clearSession()
            await validateTokensAndCheckState()
        }
    }
 
}

extension ContentViewModel{
    func getAppVersion() -> String? {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.appVersion = appVersion
            return appVersion
        }
        return nil
    }

    func getBuildNumber() -> String? {
        if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.buildNumber = buildNumber
            return buildNumber
        }
        return nil
    }
    
    func generalCheck() async throws {
        print("11")
        if let versionData = try await AuthService.shared.version() {
            print("1")
            if let version = getAppVersion(), let build = getBuildNumber() {
                print("2")
                if checkForUpdate(appVersion: version, appBuild: build, data: versionData) {
                    DispatchQueue.main.async {
                        self.authenticationState = .update
                    }
                } else {
                    print("3")
                    print("All good here")
                    await validateTokensAndCheckState()
                }
            }
        }  else {
            print("4")
            await validateTokensAndCheckState()
        }
    }
    
    func checkForUpdate(appVersion: String, appBuild: String, data: Components.Schemas.VersionInfoDto) -> Bool {
        // First check if the version is less than the minimum supported version
        if appVersion.compare(data.minVersion, options: .numeric) == .orderedAscending {
            // App version is less than the minimum required version
            return true // Suggest update
        } else if appVersion == data.minVersion {
            // If the version is the same, check the build number
            if Int(appBuild)! < Int(data.minBuild)! {
                // App build is less than the minimum required build
                return true // Suggest update
            }
        }
        // App is up to date, no need to suggest update
        return false
    }

}


//token and user session
extension ContentViewModel {
    func handleAppDidEnterBackground() {
        // Invalidate the timer when the app goes to the background
        tokenCheckTimer?.invalidate()
        tokenCheckTimer = nil
    }
    
    func miniValidation() -> Bool {
        if let _ = KeychainManager.shared.retrieve(itemForAccount: userKeys.refreshToken.toString, service: userKeys.service.toString), let accessToken = KeychainManager.shared.getToken(item: userKeys.accessToken.toString, service: userKeys.service.toString),
           !isTokenExpired(accessToken) {
            if let url = pendingURL, UIApplication.shared.canOpenURL(url) {
                DispatchQueue.main.async {
                    print("Trigger 1")
                    self.processPendingURL()
                }
            }
            return true
        } else {
            return false
        }
    }
    
    // Call this after the token refresh to handle the stored URL
    func processPendingURL() {
        print("Trigger 2")
        guard let url = pendingURL else { return }
        print("Trigger 3", url)
        // Call the URL handler here after session is refreshed
        if UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url)
            print("Trigger push")
            pendingURL = nil
        }
    }
    
    func validateTokensAndCheckState() async {
        guard let _ = KeychainManager.shared.retrieve(itemForAccount: userKeys.refreshToken.toString, service: userKeys.service.toString) else {
            DispatchQueue.main.async {
                self.authenticationState = .unauthenticated
            }
            return
        }
        
        if let accessToken = KeychainManager.shared.getToken(item: userKeys.accessToken.toString, service: userKeys.service.toString),
           !isTokenExpired(accessToken) {

            userHasBasicInfoGet(accessToken: accessToken)
        } else {
           await refreshToken()
        }
    }
    
    func validateTokens() async {
        guard let _ = KeychainManager.shared.retrieve(itemForAccount: userKeys.refreshToken.toString, service: userKeys.service.toString) else {
            DispatchQueue.main.async {
                self.authenticationState = .unauthenticated
            }
            return
        }
        
        if let accessToken = KeychainManager.shared.getToken(item: userKeys.accessToken.toString, service: userKeys.service.toString),
           !isTokenExpired(accessToken) {
            
            DispatchQueue.main.async {
                self.startTokenRefreshTimer(accessToken: accessToken)
            }
        } else {
           await refreshToken()
        }
    }
    
    func userHasBasicInfoGet(accessToken: DecodedJWTBody) {
        Task{
            if let hasBasicInfo = try await APIClient.shared.retryWithExponentialDelay(task:{ try await APIClient.shared.hasBasicInfo() }) {
                DispatchQueue.main.async {
                    if hasBasicInfo {
                        self.authenticationState = .authenticated
                        self.startTokenRefreshTimer(accessToken: accessToken)
                    } else {
                        self.authenticationState = .authenticatedNoInformation
                        self.startTokenRefreshTimer(accessToken: accessToken)
                    }                    
                }
            } else {
                AuthService.shared.clearSession()
                DispatchQueue.main.async {
                    self.authenticationState = .unauthenticated
                }
            }
        }
    }
    

    
    private func refreshToken() async {
        do {
            if try await AuthService.shared.refreshToken() {
                // Assuming refreshToken updates the accessToken in Keychain
                if let newAccessToken = KeychainManager.shared.getToken(item: userKeys.accessToken.toString, service: userKeys.service.toString) {
                    DispatchQueue.main.async {
                        self.authenticationState = .authenticated
                        self.startTokenRefreshTimer(accessToken: newAccessToken)
                        
                        print("Trigger 4")
                        if let url = self.pendingURL, UIApplication.shared.canOpenURL(url) {
                            print("Trigger 5")
                            self.processPendingURL()
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.authenticationState = .unauthenticated
                }
            }
        } catch {
            print("Error here ------- \n \(error)")
            DispatchQueue.main.async {
                self.authenticationState = .unauthenticated
            }
        }
    }
    
    private func startTokenRefreshTimer(accessToken: DecodedJWTBody) {
        //keep in mind that sessionCount handels the websocket conncetion upon user becoming active again
        DispatchQueue.main.async {
            self.sessionCount += 1
        }

        tokenCheckTimer?.invalidate()
        let timeUntilExpiration = calculateTimeUntilExpiration(accessToken)
        print(timeUntilExpiration)
        tokenCheckTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeUntilExpiration), repeats: false) { [weak self] _ in
            guard let self = self else { return }
            Task {
                await self.refreshToken()
            }
        }
    }
    
    private func calculateTimeUntilExpiration(_ token: DecodedJWTBody) -> Int {
        let currentTime = Int(Date().timeIntervalSince1970)
        return max(0, token.exp - currentTime - 300) // Refresh 5 minutes before expiration
    }
    
    private func isTokenExpired(_ token: DecodedJWTBody) -> Bool {
        let currentTime = Int(Date().timeIntervalSince1970)
        return token.exp <= currentTime
    }
    
}
