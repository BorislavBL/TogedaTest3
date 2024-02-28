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
    case eventDetails(Post)
    case usersList(users: [MiniUser], post: Post)
    case editEvent(post: Post)
    case userRequests(users: [MiniUser])
    case completedEventDetails(Post)
    case completedEventUsersList(users: [MiniUser])
    case allUserEvents(userID: String, posts: [Post])
    case bookmarkedEvents(userID: String, posts: [Post])
    case profile(MiniUser)
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
