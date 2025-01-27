//
//  UserViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 28.09.23.
//

import SwiftUI

@MainActor
class UserViewModel: ObservableObject {
    @Published var currentUser: Components.Schemas.UserInfoDto?
    @Published var friendsList: [Components.Schemas.GetFriendsDto] = []
    @Published var clubs: [Components.Schemas.ClubDto] = []
    @Published var posts: [Components.Schemas.PostResponseDto] = []
    @Published var showInstaOverlay: Bool = false
    
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
