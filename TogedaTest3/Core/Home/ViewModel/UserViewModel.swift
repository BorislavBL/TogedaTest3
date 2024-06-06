//
//  UserViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 28.09.23.
//

import SwiftUI

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User = User.MOCK_USERS[0]
    @Published var currentUserOld: User?
    @Published var currentUser: Components.Schemas.UserInfoDto?
    
    init(){
        Task{
            do {
                try await self.fetchCurrentUser()
            } catch {
                print("Error fetching data: \(error)")
            }
        }
    }
    
    func fetchCurrentUser() async throws{
        currentUser = try await APIClient.shared.getCurrentUserInfo()
    }
    
    func savePost(postId: String) {
        if !user.details.savedPostIds.contains(postId){
            user.details.savedPostIds.append(postId)
        } else {
            user.details.savedPostIds.removeAll(where: { $0 == postId })
        }
    }
    
}
