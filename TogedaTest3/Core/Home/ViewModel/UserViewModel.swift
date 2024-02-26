//
//  UserViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 28.09.23.
//

import Foundation

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User = User.MOCK_USERS[0]
    @Published var currentUser: User?

    func updateUser(_ user: User) {
        self.currentUser = user
    }
    
    func fetchCurrentUser() async throws {
        if let accessToken = KeychainManager.shared.getToken(item: userKeys.accessToken.toString, service: userKeys.service.toString) {
            currentUser = try await UserService().fetchUserDetails(userId: accessToken.username)
        }
    }
    
    func savePost(postId: String) {
        if !user.details.savedPostIds.contains(postId){
            user.details.savedPostIds.append(postId)
        } else {
            user.details.savedPostIds.removeAll(where: { $0 == postId })
        }
    }
    
}
