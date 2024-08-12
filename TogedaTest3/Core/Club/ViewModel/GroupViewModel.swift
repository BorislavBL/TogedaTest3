//
//  GroupViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 4.01.24.
//

import Foundation
import SwiftUI

class GroupViewModel: ObservableObject {
    @Published var clubMembers: [Components.Schemas.ExtendedMiniUserForClub] = []
    @Published var membersPage: Int32 = 0
    @Published var membersCount: Int64 = 0
    @Published var membersSize: Int32 = 15
    @Published var membersLastPage: Bool = true
    
    @Published var images = ["event_1", "event_2", "event_3", "event_4"]
    @Published var selectedImage: Int = 0
    @Published var joinRequestUsers: [MiniUser] = [MiniUser.MOCK_MINIUSERS[2]]
    @Published var clubs: [Components.Schemas.ClubDto] = [MockClub]
    @Published var clickedClubID: String = ""
    
    //    func fetchClub(clubId: String) async throws{
    //        if let response = try await APIClient.shared.getClub(clubID: clubId) {
    //            club = response
    //        }
    //    }
    
    func fetchClubMembers(clubId: String) async throws {
        if let response = try await APIClient.shared.getClubMembers(clubId: clubId, page: membersPage, size: membersSize) {
            DispatchQueue.main.async { [self] in
                self.clubMembers += response.data
                self.membersLastPage = response.lastPage
                
                self.membersPage += 1
                
                self.membersCount = response.listCount
            }
        }
    }
    
    @Published var clubEvents: [Components.Schemas.PostResponseDto] = []
    @Published var clubEventsPage: Int32 = 0
    @Published var clubEventsCount: Int64 = 0
    @Published var clubEventsSize: Int32 = 15
    @Published var clubEventsLastPage: Bool = true
    
    func fetchClubEvents(clubId: String) async throws {
        if let response = try await APIClient.shared.getClubEvents(clubId: clubId, page: clubEventsPage, size: clubEventsSize) {
            DispatchQueue.main.async { [weak self] in
                self?.clubEvents += response.data
                self?.clubEventsLastPage = response.lastPage
                
                self?.clubEventsPage += 1
                
                self?.clubEventsCount = response.listCount
            }
        }
    }
    
    @Published var joinRequestParticipantsList: [Components.Schemas.MiniUser] = []
    @Published var joinRequestParticipantsPage: Int32 = 0
    @Published var joinRequestParticipantsCount: Int64 = 0
    @Published var joinRequestParticipantsSize: Int32 = 15
    @Published var joinRequestLastPage = true
    
    func fetchClubJoinRequests(clubId: String) async throws {
        if let response = try await APIClient.shared.getClubJoinRequests(clubId: clubId, page: joinRequestParticipantsPage, size: joinRequestParticipantsSize) {
            DispatchQueue.main.async { [weak self] in
                self?.joinRequestParticipantsList += response.data
                self?.joinRequestLastPage = response.lastPage
                
                self?.joinRequestParticipantsPage += 1
                
                self?.joinRequestParticipantsCount = response.listCount
            }
        }
    }
    
    
    
    func updateStatuses(miniUser: Components.Schemas.MiniUser, miniClub:Components.Schemas.MiniClubDto, club: Binding<Components.Schemas.ClubDto>) {
        let user = Components.Schemas.ExtendedMiniUserForClub(user: miniUser, _type: .MEMBER)
        if !self.clubMembers.contains(user){
            self.clubMembers.insert(user, at: 0)
        }
        
        let role = miniClub.currentUserRole?.rawValue ?? club.wrappedValue.currentUserStatus.rawValue
        club.wrappedValue.currentUserRole = .init(rawValue: role) ?? club.wrappedValue.currentUserRole
        club.wrappedValue.membersCount += 1
        
    }
    
}
