//
//  MainTabViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

enum Screen: Equatable {
    case home
    case map
    case add
    case message
    case profile
}

enum SelectionPath: Hashable, Codable {
    case eventDetails(Components.Schemas.PostResponseDto)
    case usersList(users: [MiniUser], post: Post)
    case editEvent(post: Components.Schemas.PostResponseDto)
    case userRequests(users: [MiniUser])
    case completedEventDetails(post: Components.Schemas.PostResponseDto)
    case completedEventUsersList
    case allUserEvents(userID: String)
    case bookmarkedEvents(userID: String)
    case profile(Components.Schemas.MiniUser)
    case userSettings
    case editProfile
    case editProfilePhoneNumberMain
    case editProfilePhoneNumber
    case editProfilePhoneCodeVerification
    case club(Club)
    case allUserGroups(userID: String)
    case userChat(user: MiniUser)
    case notification
    case userRequest(users: [MiniUser])
    case eventReview
    case reviewMemories
    case test
}

class NavigationManager: ObservableObject {
    @Published var selectionPath = NavigationPath()
    
    //MARK: - Router
    @Published var screen: Screen = .home
    @Published var oldScreen: Screen = .home
    @Published var isPresenting = false
    
    func change(to screen: Screen) {
        self.screen = screen
    }
}
