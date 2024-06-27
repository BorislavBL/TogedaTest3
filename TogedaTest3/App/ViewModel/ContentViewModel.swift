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
}

@MainActor
class ContentViewModel: ObservableObject {
    @Published var authenticationState: AuthenticationState = .checking
    
    init(){
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        AuthClient.shared.getAccessToken { token, error in
            DispatchQueue.main.async {
                if token != nil {
                    self.userHasBasicInfoGet()
                } else {
                    self.authenticationState = .unauthenticated
                }
            }
        }
    }
    
    func logout(){
        Task{
            AuthClient.shared.loginOut()
            
            checkAuthStatus()
        }
    }
    
    func userHasBasicInfoGet() {
        Task{
            if let hasBasicInfo = try await APIClient.shared.hasBasicInfo(){
                DispatchQueue.main.async {
                    if hasBasicInfo {
                        self.authenticationState = .authenticated
                    } else {
                        self.authenticationState = .authenticatedNoInformation
                    }
                }
            } else {
                AuthClient.shared.clearSession()
                self.authenticationState = .unauthenticated
            }
        }
    }
    
}


//@MainActor
//class ContentViewModel: ObservableObject {
//    private var tokenCheckTimer: Timer?
//    @AppStorage("userId") var userId: String = ""
//    @Published var authenticationState: AuthenticationState = .checking
////    @Published var currentUser: User?
//    var userViewModel: UserViewModel?
//    
//    init(){
//        setupSubscribers()
//        
////        checkRefreshToken()
//    }
//    
//    func setupSubscribers(){
////        currentUser = User.MOCK_USERS[0]
//        userId = User.MOCK_USERS[0].id
//    }
//}
//
////token and user session
//extension ContentViewModel {
//    func checkRefreshToken() {
//        guard let _ = KeychainManager.shared.retrieve(itemForAccount: userKeys.refreshToken.toString, service: userKeys.service.toString) else {
//            authenticationState = .unauthenticated
//            return
//        }
//        
//        if let refreshTokenDeadline = KeychainManager.shared.getTokenToString(item:  userKeys.refreshTokenDeadline.toString, service: userKeys.service.toString) {
//            
//            if let refreshTokenDeadlineInt = Int(refreshTokenDeadline), isRefreshTokenExpired(refreshTokenDeadlineInt){
//                authenticationState = .unauthenticated
//                return
//            }
//            
//        } else {
//            authenticationState = .unauthenticated
//            return
//        }
//        
//        Task {
//            await validateAccessToken()
//        }
//    }
//    
//    private func validateAccessToken() async {
//        if let accessToken = KeychainManager.shared.getToken(item: userKeys.accessToken.toString, service: userKeys.service.toString),
//           !isTokenExpired(accessToken) {
//            self.authenticationState = .authenticated
//            await fetchUserDetailsAndUpdateState(with: accessToken.username)
//            self.startTokenRefreshTimer(accessToken: accessToken)
//        } else {
//            await refreshTokenAndFetchUser()
//        }
//    }
//    
//    private func refreshTokenAndFetchUser() async {
//        do {
//            try await AuthService.shared.refreshToken()
//            self.authenticationState = .authenticated
//            // Assuming refreshToken updates the accessToken in Keychain
//            if let newAccessToken = KeychainManager.shared.getToken(item: userKeys.accessToken.toString, service: userKeys.service.toString) {
//                await fetchUserDetailsAndUpdateState(with: newAccessToken.username)
//                self.startTokenRefreshTimer(accessToken: newAccessToken)
//            }
//        } catch GeneralError.badRequest(details: let details) {
//            print("Error: \(details)")
//            self.authenticationState = .unauthenticated
//        } catch GeneralError.serverError(statusCode: _, details: let details){
//            print("Error: \(details)")
//            self.authenticationState = .unauthenticated
//        }
//        catch {
//            print("Error handling refresh token or fetching user:", error)
//            self.authenticationState = .unauthenticated
//        }
//    }
//    
//    private func fetchUserDetailsAndUpdateState(with userId: String) async {
//        do {
//            let user = try await UserService().fetchUserDetails(userId: userId)
//
//            DispatchQueue.main.async { [weak self] in
//                self?.userViewModel?.updateUser(user)
//                self?.userId = userId
//            }
//        } catch {
//            print("Failed to fetch user details:", error)
//            // Decide how to handle user detail fetch failure
//        }
//    }
//    
//    private func startTokenRefreshTimer(accessToken: DecodedJWTBody) {
//        tokenCheckTimer?.invalidate()
//        let timeUntilExpiration = calculateTimeUntilExpiration(accessToken)
//        print(timeUntilExpiration)
//        tokenCheckTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeUntilExpiration), repeats: false) { [weak self] _ in
//            Task {
//                await self?.refreshTokenAndFetchUser()
//            }
//        }
//    }
//    
//    private func calculateTimeUntilExpiration(_ token: DecodedJWTBody) -> Int {
//        let currentTime = Int(Date().timeIntervalSince1970)
//        return max(0, token.exp - currentTime - 300) // Refresh 5 minutes before expiration
//    }
//    
//    private func isTokenExpired(_ token: DecodedJWTBody) -> Bool {
//        let currentTime = Int(Date().timeIntervalSince1970)
//        return token.exp <= currentTime
//    }
//    
//    private func isRefreshTokenExpired(_ exp: Int) -> Bool {
//        let currentTime = Int(Date().timeIntervalSince1970)
//        return exp <= (currentTime + 172800) //two days grace period
//    }
//}
