//
//  PostsViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation
import Combine
import MapKit

class PostsViewModel: ObservableObject {

    @Published var clickedPostIndex: Int = 0
    @Published var clickedPost: Components.Schemas.PostResponseDto = MockPost
    
    @Published var showDetailsPage = false
    @Published var showPostOptions = false
    @Published var selectedOption = "None"
    @Published var showJoinRequest = false
    
    @Published var showSharePostSheet: Bool = false
    @Published var showReportEvent = false

    //Monolith implementation
    @Published var feedPosts: [Components.Schemas.PostResponseDto] = []
    @Published var lastPage: Bool = true
    
    @Published var page: Int32 = 0
    @Published var size: Int32 = 15
    @Published var lat: Double = 43
    @Published var long: Double = 39
    @Published var distance: Int = 300
    @Published var from: Date? = nil
    @Published var to: Date? = nil
    @Published var categories: [String]? = nil
    
    private var locationCancellables = Set<AnyCancellable>()
    private var locationManager = LocationManager()
    
    init() {
        locationManager.$location
            .compactMap { $0 } // Ensure the location is not nil
            .first() // Take only the first non-nil location
            .sink { [weak self] location in
                guard let self = self else { return }
                DispatchQueue.main.async{
                    self.lat = location.coordinate.latitude
                    self.long = location.coordinate.longitude
                }
                Task {
                    try await self.fetchPosts()
                }
            }
            .store(in: &locationCancellables)
    }
    
    func applyFilter(lat: Double, long: Double, distance: Int, from: Date?, to: Date?, categories: [String]?) async throws {
        page = 0
        feedPosts = []
        lastPage = true
        
        DispatchQueue.main.async{
            self.lat = lat
            self.long = long
            self.distance = distance
            self.from = from
            self.to = to
            self.categories = categories
        }
        
        Task{
            try await self.fetchPosts()
        }
    }
    
    func fetchPosts() async throws {
//        print("Page: \(page), Seize: \(size), Cord: \(lat), \(long), Distance: \(distance), date: \(from), \(to)")
        
        if let response = try await APIClient.shared.getAllEvents(
            page: page,
            size: size,
            long: long,
            lat: lat,
            distance: Int32(distance),
            from: from,
            to: to, 
            categories: categories
            ) {
            
            DispatchQueue.main.async{
                self.feedPosts += response.data
                self.lastPage = response.lastPage
                self.page += 1
            }
        }
    }
    
    func feedScrollFetch(index: Int) {
        if !lastPage {
            if index == feedPosts.count - 7 {
                Task{
                   try await self.fetchPosts()
                }
            }
        }
    }
    
    func localEventFetch(postId: String) -> Components.Schemas.PostResponseDto? {
        if let index = feedPosts.firstIndex(where: { $0.id == postId }) {
            return feedPosts[index]
        }
        
        return nil
    }
    
    func joinRequest(postId: String) async throws {
            if try await APIClient.shared.joinEvent(postId: postId) != nil {
                try await self.refreshEventOnAction(postId: postId)
            }
    }
    
    func refreshEventOnAction(postId: String) async throws {

            if let response = try await APIClient.shared.getEvent(postId: postId) {
                if let index = feedPosts.firstIndex(where: { $0.id == postId }) {
                    DispatchQueue.main.async{
                        self.feedPosts[index] = response
                    }
                }
            }
    }
    
    func refreshEventOnAppear(index: Int, postId: String) async throws {
            if let response = try await APIClient.shared.getEvent(postId: postId) {
                DispatchQueue.main.async{
                    self.feedPosts[index] = response
                }
            }
    }
    
    func deleteEvent(postId: String) async throws {
            if try await APIClient.shared.deleteEvent(postId: postId) != nil {
                if let index = feedPosts.firstIndex(where: { $0.id == postId }) {
                    DispatchQueue.main.async{
                        self.feedPosts.remove(at: index)
                    }
                }
            }
    }
    
    func saveEvent(postId: String) async throws -> Bool? {
        if let index = feedPosts.firstIndex(where: { $0.id == postId }) {
            if feedPosts[index].savedByCurrentUser {
                if try await APIClient.shared.saveOrUnsaveEvent(postId: postId, isSave: false) != nil {
                    DispatchQueue.main.async{
                        self.feedPosts[index].savedByCurrentUser = false
                    }
                    return false
                }
            } else {
                if try await APIClient.shared.saveOrUnsaveEvent(postId: postId, isSave: true) != nil {
                    DispatchQueue.main.async{
                        self.feedPosts[index].savedByCurrentUser = true
                    }
                    return true
                }
            }
        }
        
        return nil
    }

}
