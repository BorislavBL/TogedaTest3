//
//  EventViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.05.24.
//

import Foundation
import SwiftUI

class EventViewModel: ObservableObject {
    @Published var participantsList: [Components.Schemas.ExtendedMiniUser] = []
    @Published var participantsPage: Int32 = 0
    @Published var participantsSize: Int32 = 15
    @Published var participantsCount: Int64 = 0
    @Published var listLastPage = true
    
    func fetchUserList(id: String) async throws{
        if let response = try await APIClient.shared.getEventParticipants(
            postId: id,
            page: participantsPage,
            size: participantsSize) {
            
            DispatchQueue.main.async {
                self.participantsList += response.data
                self.participantsPage += 1
                self.listLastPage = response.lastPage
                self.participantsCount = response.listCount
            }
        }
    }
    
    @Published var joinRequestParticipantsList: [Components.Schemas.MiniUser] = []
    @Published var joinRequestParticipantsPage: Int32 = 0
    @Published var joinRequestParticipantsSize: Int32 = 15
    @Published var joinRequestLastPage = true
    
    func fetchJoinRequestUserList(id: String) async throws{
        if let response = try await APIClient.shared.getEventParticipantsWaitingList(
            postId: id,
            page: joinRequestParticipantsPage,
            size: joinRequestParticipantsSize) {
            
            DispatchQueue.main.async {
                self.joinRequestParticipantsList += response.data
                self.joinRequestParticipantsPage += 1
                self.joinRequestLastPage = response.lastPage
            }
        }
    }
    
    @Published var waitingList: [Components.Schemas.MiniUser] = []
    @Published var waitingListPage: Int32 = 0
    @Published var waitingListSize: Int32 = 15
    @Published var waitingListLastPage = true
    
    func fetchWaitingList(id: String) async throws{
        if let response = try await APIClient.shared.getEventWaitlist(
            postId: id,
            page: waitingListPage,
            size: waitingListSize) {
            
            DispatchQueue.main.async {
                self.waitingList += response.data
                self.waitingListPage += 1
                self.waitingListLastPage = response.lastPage
            }
        }
    }
    
    func updateEvent(not: Components.Schemas.NotificationDto, post: Binding<Components.Schemas.PostResponseDto>){
        if let not = not.alertBodyAcceptedJoinRequest {
            if post.wrappedValue.askToJoin{
                if let minipost = not.post, minipost.id == post.wrappedValue.id {
                    updateStatuses(miniUser: not.acceptedUser, miniPost: minipost, post: post)
                }
            }
        } else if let not = not.alertBodyPostHasStarted {
            post.wrappedValue.status =  .HAS_STARTED
            post.wrappedValue.currentUserStatus = .init(rawValue: not.post.currentUserStatus.rawValue) ?? post.wrappedValue.currentUserStatus
            if let role = not.post.currentUserRole{
                post.wrappedValue.currentUserRole = .init(rawValue: role.rawValue) ?? post.wrappedValue.currentUserRole
            }
        } else if let not = not.alertBodyReviewEndedPost {
            post.wrappedValue.status = .HAS_ENDED
            post.wrappedValue.currentUserStatus = .init(rawValue: not.post.currentUserStatus.rawValue) ?? post.wrappedValue.currentUserStatus
            if let role = not.post.currentUserRole{
                post.wrappedValue.currentUserRole = .init(rawValue: role.rawValue) ?? post.wrappedValue.currentUserRole
            }
        }
        
    }
    
    func updateStatuses(miniUser: Components.Schemas.MiniUser, miniPost:Components.Schemas.MiniPostDto, post: Binding<Components.Schemas.PostResponseDto>) {
        let currentUserRole = miniPost.currentUserRole?.rawValue ?? "NORMAL"
        let user = Components.Schemas.ExtendedMiniUser(user: miniUser, _type: .init(rawValue: currentUserRole) ?? .NORMAL, locationStatus: post.wrappedValue.needsLocationalConfirmation ? .NOT_SHOWN : .NONE)
        if !self.participantsList.contains(user){
            self.participantsList.insert(user, at: 0)
        }
        
        let role = miniPost.currentUserRole?.rawValue ?? post.wrappedValue.currentUserStatus.rawValue
        let status = miniPost.currentUserStatus.rawValue
        post.wrappedValue.currentUserStatus = .init(rawValue: status) ?? post.wrappedValue.currentUserStatus
        post.wrappedValue.currentUserRole = .init(rawValue: role) ?? post.wrappedValue.currentUserRole
        post.wrappedValue.participantsCount += 1
        
    }
    
    
}
