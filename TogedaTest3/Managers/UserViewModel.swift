//
//  UserViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 28.09.23.
//

import SwiftUI

@MainActor
class UserViewModel: ObservableObject {
    @Published var currentUser: Components.Schemas.UserInfoDto? {
        didSet {
            if let user = currentUser {
                miniCurrentUser = UserToMiniUser(user: user)
//                if oldValue?.stripeAccountId != currentUser?.stripeAccountId {
                    if let accountId = user.stripeAccountId {
                        Task {
                            try await checkForStripeWarning(accountId: accountId)
                        }
                    }
//                }
            } else {
                miniCurrentUser = nil
            }
        }
    }
    @Published var miniCurrentUser: Components.Schemas.MiniUser?
    @Published var friendsList: [Components.Schemas.GetFriendsDto] = []
    @Published var clubs: [Components.Schemas.ClubDto] = []
    @Published var posts: [Components.Schemas.PostResponseDto] = []
    @Published var showInstaOverlay: Bool = false
    
    @Published var hasPaidEvents: Bool = false
    @Published var isOnBoardingDone = false
    @Published var showStripeWarrning = false
    @Published var hasAccountInformation = true
    @Published var userStripeAccountInformation: Components.Schemas.StripeAccountDto?
    
    // MARK: - Cooldown state (lives only in memory; resets on cold app start)
    @Published private var stripeWarningLastShownAt: Date? = nil
    private let stripeWarningCooldown: TimeInterval = 60 * 60 * 24 // 1 day

    private func canPresentStripeWarning(now: Date = Date()) -> Bool {
        guard let last = stripeWarningLastShownAt else { return true }
        return now.timeIntervalSince(last) >= stripeWarningCooldown
    }
    
    func addPost(post: Components.Schemas.PostResponseDto) {
        if !posts.contains(where: {$0.id == post.id}) {
            posts.insert(post, at: 0)
        }
    }
    
    func removePost(post: Components.Schemas.PostResponseDto) {
        posts.removeAll(where: {$0.id == post.id})
    }
    
    func addClub(club: Components.Schemas.ClubDto) {
        if !clubs.contains(where: {$0.id == club.id}) {
            clubs.insert(club, at: 0)
        }
    }
    
    func removeClub(club: Components.Schemas.ClubDto) {
        clubs.removeAll(where: {$0.id == club.id})
    }
    
    init(){
//        self.retryFetchUser()
//        Task{
//            do {
//                try await fetchCurrentUser()
//                print("End user fetch")
//            } catch {
//                // Handle the error if needed
//                print("Error fetching data: \(error)")
//            }
//        }
    }
    
    func retryFetchUser() async throws{
        currentUser = try await APIClient.shared.retryWithExponentialDelay(task:{ try await APIClient.shared.getCurrentUserInfo()})
    }
    
    func fetchCurrentUser() async throws{
        currentUser = try await APIClient.shared.getCurrentUserInfo()
    }
}

extension UserViewModel {
    func stripeAccountInformation() async throws {
        do {
            if let response = try await APIClient.shared.getStripeAccountInfo() {
                DispatchQueue.main.async {
                    self.userStripeAccountInformation = response
                    self.hasAccountInformation = true
                }
            }
        } catch AppError.internalServerError(_){
            DispatchQueue.main.async {
                self.hasAccountInformation = false
            }
        }
    }
    
    func stripeOnBordingStatus(accountId: String) async throws -> Bool?{
        if let response = try await APIClient.shared.stripeOnBordingStatus(accountId: accountId) {
            print(response)
            if let bool = Bool(response.data) {
                DispatchQueue.main.async {
                    self.isOnBoardingDone = bool
                }
                return bool
            }
        }
        return nil
    }
    
    func checkForPaidEvent() async throws -> Bool? {
        if let response = try await APIClient.shared.checkForPaidEvents() {
            if let bool = Bool(response.data) {
                DispatchQueue.main.async {
                    self.hasPaidEvents = bool
                }
                return bool
            }
        }
        return nil
    }
    
    func checkForStripeWarning(accountId: String) async throws {
        // Throttle based on in-memory cooldown; if within 24h, do nothing.
        guard canPresentStripeWarning() else { return }

        if let onboarded = try await stripeOnBordingStatus(accountId: accountId), !onboarded {
            if let hasPaid = try await checkForPaidEvent(), hasPaid {
                DispatchQueue.main.async {
                    self.showStripeWarrning = true
                    // Mark the time we showed the warning so we throttle next time.
                    self.stripeWarningLastShownAt = Date()
                }
            }
        }
    }
}
