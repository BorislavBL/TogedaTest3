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
    @Published var clubsCount: Int64 = 0
    @Published var postsCount: Int64 = 0
    
    @Published var likesCount: Int64 = 0
    @Published var noShows: Int32 = 0
    @Published var badges: [Components.Schemas.Badge] = []
    @Published var badgeTasks: [Components.Schemas.BadgeTask] = []

    
    func getUserClubs(userId: String) async throws {
        if let response = try await APIClient.shared.getUserClubs(userId: userId, page: 0, size: 15) {
            DispatchQueue.main.async {
                self.clubs = response.data
                self.clubsCount = response.listCount
            }
           
        }
    }
    
    func getUserPosts(userId: String) async throws {
        if let response = try await APIClient.shared.getUserEvents(userId: userId, page: 0, size: 15) {
            DispatchQueue.main.async {
                self.posts = response.data
                self.postsCount = response.listCount
            }
        }
    }
    
    func updateUser(not: Components.Schemas.NotificationDto, user: Binding<Components.Schemas.UserInfoDto?>){
        if not.alertBodyAcceptedJoinRequest != nil {
            user.wrappedValue?.currentFriendshipStatus = .FRIENDS
        } else if not.alertBodyReceivedJoinRequest != nil {
            user.wrappedValue?.currentFriendshipStatus = .RECEIVED_FRIEND_REQUEST
        }
    }
    
    func fetchAllData(userId: String) async {
        // Use a task group to fetch all data concurrently
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    try await self.getUserPosts(userId: userId)
                } catch {
                    print("Error fetching user posts: \(error)")
                }
            }
            
            group.addTask {
                do {
                    if let response = try await APIClient.shared.getUserNoShows(userId: userId) {
                        DispatchQueue.main.async{
                            self.noShows = response
                        }
                    }
                } catch {
                    print("Error fetching user posts: \(error)")
                }
            }
            
            group.addTask {
                do {
                    if let response = try await APIClient.shared.getUserLikesList(userId: userId, page: 0, size: 1) {
                        DispatchQueue.main.async{
                            self.likesCount = response.listCount
                        }
                    }
                } catch {
                    print("Error fetching user posts: \(error)")
                }
            }
            
            group.addTask {
                do {
                    try await self.getUserClubs(userId: userId)
                } catch {
                    print("Error fetching user clubs: \(error)")
                }
            }
            
            group.addTask {
                do {
                    if let response = try await APIClient.shared.getUserLikesList(userId: userId, page: 0, size: 1) {
                        DispatchQueue.main.async {
                            self.likesCount = response.listCount
                        }
                    }
                } catch {
                    print("Error fetching user clubs: \(error)")
                }
            }
            
            group.addTask {
                do {
                    if let response = try await APIClient.shared.getBadges() {
                        if response.count > 0 {
                            DispatchQueue.main.async {
                                self.badges = response
                            }
                        }
                    }
                } catch {
                    print("Error fetching user clubs: \(error)")
                }
            }
            
            group.addTask {
                do {
                    if let badgeTasks = try await APIClient.shared.getBadgeTasks() {
                        DispatchQueue.main.async {
                            print("BadgesTasks: \(badgeTasks)")
                            self.badgeTasks = badgeTasks.filter { task in
                                return task.completionNumber != task.currentNumber
                            }
                        }
                    }
                } catch {
                    print("Error fetching user clubs: \(error)")
                }
            }
        }
    }
}


