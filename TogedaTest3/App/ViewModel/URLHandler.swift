//
//  URLHandler.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 21.06.24.
//

import Foundation
import SwiftUI
import Combine

class URLHandler {
    private var navigationManager: NavigationManager
    
    init(navigationManager: NavigationManager) {
        self.navigationManager = navigationManager
    }
    
    func handleURL(_ url: URL) {
        print("URLLLLLLL: \(url)")
        var URL = transformURL(url: url)
        if URL.host == "event" {
            handleEventURL(URL)
        } else if URL.host == "user" {
            handleUserURL(URL)
        } else if URL.host == "club" {
            handleClubURL(URL)
        } else if URL.host == "review" {
            handleEventReviewURL(URL)
        } else if URL.host == "joinRequest" {
            handleJoinRequestURL(URL)
        } else if URL.host == "chatRoom" {
            handleChatroomURL(URL)
        } else if URL.host == "support" {
            handleSupportURL()
        }
    }
    
    func transformURL(url: URL) -> URL {
        // Check if the URL contains "api.togeda.net" and has the "in-app" path component
        if let host = url.host, host.contains("api.togeda.net") {
            if var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                // Modify the scheme to `togedaapp`
                components.scheme = "togedaapp"
                
                // Remove the "api.togeda.net" part, and adjust the host/path as needed
                if let firstPath = components.path.split(separator: "/").first, firstPath == "in-app" {
                    components.host = components.path.split(separator: "/").dropFirst().first.map { String($0) } // Set host to the next path component (event, user, etc.)
                    components.path = "/" + components.path.split(separator: "/").dropFirst(2).joined(separator: "/") // Remove "in-app" and next component from path
                }
                
                // Return transformed URL, or original if transformation fails
                return components.url ?? url
            }
        }
        
        // Return the original URL if no transformation is needed
        return url
    }

    
    private func handleEventURL(_ url: URL) {
        if let queryParameters = url.queryParameters,
           let id = queryParameters["id"] {
            Task {
                if let response = try await APIClient.shared.getEvent(postId: id) {
                    DispatchQueue.main.async{
//                        if response.status != .HAS_ENDED {
                            self.navigationManager.selectionPath.append(.eventDetails(response))
//                        } else {
//                            self.navigationManager.selectionPath.append(.completedEventDetails(post: response))
//                        }
                    }
                }
            }
        }
    }
    
    private func handleUserURL(_ url: URL) {
        if let queryParameters = url.queryParameters,
           let id = queryParameters["id"] {
            Task {
                if let response = try await APIClient.shared.getUserInfo(userId: id) {
                    let miniUser = Components.Schemas.MiniUser(id: response.id, firstName: response.firstName, lastName: response.lastName, profilePhotos: response.profilePhotos, occupation: response.occupation, location: response.location, birthDate: response.birthDate, userRole: .init(rawValue: response.userRole.rawValue) ?? .NORMAL)
                    DispatchQueue.main.async{
                        self.navigationManager.selectionPath.append(.profile(miniUser))
                    }
                }
            }
        }
    }
    
    private func handleClubURL(_ url: URL) {
        if let queryParameters = url.queryParameters,
           let id = queryParameters["id"] {
            Task {
                if let response = try await APIClient.shared.getClub(clubID: id) {
                    DispatchQueue.main.async{
                        self.navigationManager.selectionPath.append(.club(response))
                    }
                }
            }
        }
    }
    
    private func handleChatroomURL(_ url: URL) {
        if let queryParameters = url.queryParameters,
           let id = queryParameters["id"] {
            Task {
                if let response = try await APIClient.shared.getChat(chatId: id) {
                    DispatchQueue.main.async{
                        self.navigationManager.screen = .message
                        self.navigationManager.selectionPath = [.userChat(chatroom: response)]
                    }
                }
            }
        }
    }
    
    private func handleEventReviewURL(_ url: URL) {
        if let queryParameters = url.queryParameters,
           let id = queryParameters["id"] {
            Task {
                if let response = try await APIClient.shared.getEvent(postId: id) {
                    DispatchQueue.main.async{
//                        if response.currentUserRole == .NORMAL {
//                            self.navigationManager.selectionPath.append(.eventReview(post: response))
//                        } else {
//                            self.navigationManager.selectionPath.append(.rateParticipants(post: response, rating: .init(value: Double(5), comment: nil)))
//                        }
                        self.navigationManager.activateReviewSheet = true
                        self.navigationManager.selectionPath.append(.notification)
                    }
                }
            }
        }
    }
    
    private func handleSupportURL() {
        DispatchQueue.main.async{
            self.navigationManager.selectionPath.append(.userSettings(isSupportNeeded: true))
        }
    }
    
    
    private func handleJoinRequestURL(_ url: URL) {
        if let queryParameters = url.queryParameters,
           let type = queryParameters["type"], let id = queryParameters["id"] {
            if type == "event"{
                Task {
                    if let response = try await APIClient.shared.getEvent(postId: id) {
                        DispatchQueue.main.async{
                            if response.currentUserRole == .CO_HOST || response.currentUserRole == .HOST{
//                                if response.status != .HAS_ENDED {
                                    self.navigationManager.selectionPath.append(.eventDetails(response))
                                    self.navigationManager.selectionPath.append(.eventUserJoinRequests(post: response))
//                                } else {
//                                    self.navigationManager.selectionPath.append(.completedEventDetails(post: response))
//                                }
                            }
                        }
                    }
                }
            } else if type == "club"{
                Task {
                    if let response = try await APIClient.shared.getClub(clubID: id) {
                        DispatchQueue.main.async{
                            if response.currentUserRole == .ADMIN{
                                self.navigationManager.selectionPath.append(.club(response))
                                self.navigationManager.selectionPath.append(.clubJoinRequests(response))
                            }
                        }
                    }
                }
            }
        }
    }
}

extension URL {
    public var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value?.replacingOccurrences(of: "+", with: " ")
        }
    }
}
