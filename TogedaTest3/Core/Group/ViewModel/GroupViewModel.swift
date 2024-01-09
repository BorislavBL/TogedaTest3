//
//  GroupViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 4.01.24.
//

import Foundation

class GroupViewModel: ObservableObject {
    @Published var club: Club = Club.MOCK_CLUBS[0]
    @Published var images = ["event_1", "event_2", "event_3", "event_4"]
    @Published var selectedImage: Int = 0
    @Published var joinRequestUsers: [MiniUser] = [MiniUser.MOCK_MINIUSERS[2]]
    @Published var clubs: [Club] = Club.MOCK_CLUBS
    @Published var clickedClubID: String = Club.MOCK_CLUBS[0].id
    
    func fetchClub(clubID: String) {
        self.club = Club.MOCK_CLUBS.first(where: {$0.id == clubID}) ?? Club.MOCK_CLUBS[0]
//        self.joinRequestUsers = MiniUser.MOCK_MINIUSERS.filter{ self.club.joinRequestUsers.contains($0.id)}
//        self.club.events = Post.MOCK_POSTS.filter{ self.club.eventIDs.contains($0.id)}
    }
}
