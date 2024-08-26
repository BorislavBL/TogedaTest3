//
//  MainTabViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import Combine

enum Screen: Equatable {
    case home
    case map
    case add
    case message
    case profile
}

enum SelectionPath: Hashable, Codable {
    case eventDetails(Components.Schemas.PostResponseDto)
    case usersList(post: Components.Schemas.PostResponseDto)
//    case editEvent(post: Components.Schemas.PostResponseDto)
    case eventUserJoinRequests(post: Components.Schemas.PostResponseDto)
    case completedEventDetails(post: Components.Schemas.PostResponseDto)
    case allUserEvents(userID: String)
    case bookmarkedEvents(userID: String)
    case profile(Components.Schemas.MiniUser)
    case userSettings
    case userFriendsList(Components.Schemas.UserInfoDto)
    case userFriendRequestsList
    case editProfile
    case editProfilePhoneNumberMain
    case editProfilePhoneNumber
    case editProfilePhoneCodeVerification
    case club(Components.Schemas.ClubDto)
    case clubJoinRequests(Components.Schemas.ClubDto)
    case eventWaitingList(Components.Schemas.PostResponseDto)
//    case editClubView(Components.Schemas.ClubDto)
    case allClubEventsView(String)
    case allUserGroups(userID: String)
    case clubMemersList(Components.Schemas.ClubDto)
    case userChat(chatroom: Components.Schemas.ChatRoomDto)
    case notification
    case userRequest
    case eventReview(post: Components.Schemas.PostResponseDto)
    case reviewMemories
    case rateParticipants(post: Components.Schemas.PostResponseDto, rating: Components.Schemas.RatingDto)
    case userReviewView(user: Components.Schemas.UserInfoDto)
    case paymentPage
    case chatParticipants(chatId: String)
    case test
}


class NavigationManager: ObservableObject {
    @Published var selectionPath: [SelectionPath] = [] //NavigationPath()
    
    //MARK: - Router
    @Published var screen: Screen = .home
    @Published var oldScreen: Screen = .home
    @Published var isPresentingEvent = false
    @Published var isPresentingClub = false
    @Published var homeScrollTop = false
    
    func change(to screen: Screen) {
        self.screen = screen
    }
    
    private var cancellable: AnyCancellable?
    
    init() {
        listenForTabSelection()
    }
    
    deinit {
        cancellable?.cancel()
        cancellable = nil
    }
    
    private func listenForTabSelection() {
        cancellable = $screen
            .sink { [weak self] newTab in
                guard let self = self else { return }
                if newTab == self.screen {
                    switch newTab {
                    case .home:
                        homeScrollTop.toggle()
                    case .map:
                        print("Map")
                    case .add:
                        print("Add")
                    case .message:
                        print("Message")
                    case .profile:
                        print("Profile")
                    }
                }
            }
    }
    
}
