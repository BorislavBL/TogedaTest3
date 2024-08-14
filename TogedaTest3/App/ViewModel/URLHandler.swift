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
        if url.host == "event" {
            handleEventURL(url)
        } else if url.host == "user" {
            handleUserURL(url)
        } else if url.host == "club" {
            handleClubURL(url)
        } else if url.host == "review" {
            handleEventReviewURL(url)
        } else if url.host == "joinRequest" {
           handleJoinRequestURL(url)
        }
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
                    let miniUser = Components.Schemas.MiniUser(id: response.id, firstName: response.firstName, lastName: response.lastName, profilePhotos: response.profilePhotos, occupation: response.occupation, location: response.location, birthDate: response.birthDate)
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
    
    private func handleEventReviewURL(_ url: URL) {
        if let queryParameters = url.queryParameters,
           let id = queryParameters["id"] {
            Task {
                if let response = try await APIClient.shared.getEvent(postId: id) {
                    DispatchQueue.main.async{
                        if response.currentUserRole == .NORMAL {
                            self.navigationManager.selectionPath.append(.eventReview(post: response))
                        } else {
                            self.navigationManager.selectionPath.append(.rateParticipants(post: response, rating: .init(value: Double(5), comment: nil)))
                        }
                    }
                }
            }
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
