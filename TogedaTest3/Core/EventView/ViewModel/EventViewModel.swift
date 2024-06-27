//
//  EventViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.05.24.
//

import Foundation

class EventViewModel: ObservableObject {
    @Published var participantsList: [Components.Schemas.ExtendedMiniUser] = []
    @Published var participantsPage: Int32 = 0
    @Published var participantsSize: Int32 = 15
    @Published var participantsCount: Int32 = 0
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
    
}
