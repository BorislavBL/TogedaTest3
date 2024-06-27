//
//  GroupViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 4.01.24.
//

import Foundation

class GroupViewModel: ObservableObject {
    @Published var clubMembers: [Components.Schemas.ExtendedMiniUserForClub] = []
    @Published var membersPage: Int32 = 0
    @Published var membersCount: Int32 = 0
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
                self?.membersCount = response.listCount
            }
        }
    }
    
    @Published var clubEvents: [Components.Schemas.PostResponseDto] = []
    @Published var clubEventsPage: Int32 = 0
    @Published var clubEventsCount: Int32 = 0
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
    @Published var joinRequestParticipantsCount: Int32 = 0
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
    
    func fetchAllData(clubId: String) async {
        // Use a task group to fetch all data concurrently
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    try await self.fetchClubMembers(clubId: clubId)
                } catch {
                    print("Error fetching user posts: \(error)")
                }
            }
            
            group.addTask {
                do {
                    try await self.fetchClubEvents(clubId: clubId)
                } catch {
                    print("Error fetching user clubs: \(error)")
                }
            }
        }
    }

}
