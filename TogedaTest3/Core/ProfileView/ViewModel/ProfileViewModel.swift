//
//  ProfileViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

class ProfileViewModel: ObservableObject {

    @Published var clubs: [Components.Schemas.ClubDto] = []
    @Published var posts: [Components.Schemas.PostResponseDto] = []
    
    func getUserClubs(userId: String) async throws {
        if let response = try await APIClient.shared.getUserClubs(userId: userId, page: 0, size: 15) {
            DispatchQueue.main.async {
                self.clubs = response.data
            }
           
        }
    }
    
    func getUserPosts(userId: String) async throws {
        if let response = try await APIClient.shared.getUserEvents(userId: userId, page: 0, size: 15) {
            DispatchQueue.main.async {
                self.posts = response.data
            }
        }
    }
}


