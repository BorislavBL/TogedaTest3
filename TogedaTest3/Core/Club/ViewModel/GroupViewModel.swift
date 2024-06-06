//
//  GroupViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 4.01.24.
//

import Foundation

class GroupViewModel: ObservableObject {
    @Published var clubMembers: [Components.Schemas.ExtendedMiniUserForClub] = []
    @Published var clubEvents: [Components.Schemas.PostResponseDto] = []
    @Published var membersPage: Int32 = 0
    @Published var membersSize: Int32 = 15
    @Published var membersLastPage: Bool = true
    
    @Published var images = ["event_1", "event_2", "event_3", "event_4"]
    @Published var selectedImage: Int = 0
    @Published var joinRequestUsers: [MiniUser] = [MiniUser.MOCK_MINIUSERS[2]]
    @Published var clubs: [Club] = Club.MOCK_CLUBS
    @Published var clickedClubID: String = Club.MOCK_CLUBS[0].id
    
//    func fetchClub(clubId: String) async throws{
//        if let response = try await APIClient.shared.getClub(clubID: clubId) {
//            club = response
//        }
//    }
    
    func fetchClubMembers(clubId: String) async throws {
        if let response = try await APIClient.shared.getClubMembers(clubId: clubId, page: membersPage, size: membersSize) {
            DispatchQueue.main.async { [weak self] in
                self?.clubMembers += response.data
                self?.membersLastPage = response.lastPage
                self?.membersPage += 1
            }
        }
    }
    
    func fetchClubEvents(clubId: String) async throws {
        if let response = try await APIClient.shared.getClubMembers(clubId: clubId, page: membersPage, size: membersSize) {
            DispatchQueue.main.async { [weak self] in
                self?.clubMembers += response.data
                self?.membersLastPage = response.lastPage
                self?.membersPage += 1
            }
        }
    }
    
    @Published var joinRequestParticipantsList: [Components.Schemas.MiniUser] = []
    @Published var joinRequestParticipantsPage: Int32 = 0
    @Published var joinRequestParticipantsSize: Int32 = 15
    @Published var joinRequestLastPage = true
    
    func fetchClubJoinRequests(clubId: String) async throws {
        if let response = try await APIClient.shared.getClubJoinRequests(clubId: clubId, page: joinRequestParticipantsPage, size: joinRequestParticipantsSize) {
            DispatchQueue.main.async { [weak self] in
                self?.joinRequestParticipantsList += response.data
                self?.joinRequestLastPage = response.lastPage
                self?.joinRequestParticipantsPage += 1
            }
        }
    }

}
