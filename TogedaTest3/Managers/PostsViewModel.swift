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
    @Published var showInstaOverlay = false
    @Published var clickedPostIndex: Int = 0
    @Published var clickedPost: Components.Schemas.PostResponseDto = MockPost
    
    @Published var showDetailsPage = false
    //    @Published var showPostOptions = false
    @Published var selectedOption = "None"
    @Published var showJoinRequest = false
    @Published var showPaymentView = false
    
    @Published var showSharePostSheet: Bool = false
    @Published var showReportEvent = false
    
    //Monolith implementation
    @Published var feedPosts: [Components.Schemas.PostResponseDto] = []
    @Published var lastPage: Bool = true
    @Published var feedPostsInit: Bool = true
    
    @Published var state: LoadingCases = .loading
    @Published var indexLoadingState: LoadingCases = .noResults
    
    @Published var page: Int32 = 0
    @Published var size: Int32 = 15
    @Published var sortBy: Operations.getAllPosts.Input.Query.sortByPayload = .CREATED_AT
    @Published var lat: Double = 43
    @Published var long: Double = 39
    @Published var distance: Int = 3000000
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
                
                
                //                self.retryFetchPosts()        
                Task {
                    await withCheckedContinuation { continuation in
                        DispatchQueue.main.async{
                            self.lat = location.coordinate.latitude
                            self.long = location.coordinate.longitude
                            self.locationManager.stopLocation()
                            continuation.resume()
                        }
                    }
                    do {
                        try await self.fetchPosts()
                    } catch {
                        print("Error fetching data: \(error)")
                    }
                    
                }
                
            }
            .store(in: &locationCancellables)
    }
    
    func retryFetchPosts() {
        Task {
            while true {
                do {
                    try await fetchPosts()
                    break // Exit loop if fetchPosts succeeds
                } catch {
                    // Handle the error if needed
                    try await Task.sleep(nanoseconds: 20_000_000_000)
                    print("Error fetching data: \(error)")
                }
            }
        }
    }
    
    func applyFilter(sort: Operations.getAllPosts.Input.Query.sortByPayload, lat: Double, long: Double, distance: Int, from: Date?, to: Date?, categories: [String]?) async throws {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                self.sortBy = sort
                self.page = 0
                self.feedPosts = []
                self.lastPage = true
                
                self.lat = lat
                self.long = long
                self.distance = distance
                self.from = from
                self.to = to
                self.categories = categories
                
                self.state = .loading
                
                continuation.resume()
            }
        }
        
        try await self.fetchPosts()
    }
    
    func fetchPosts() async throws {
        //        print("Page: \(page), Seize: \(size), Cord: \(lat), \(long), Distance: \(distance), date: \(from), \(to)")
        DispatchQueue.main.async{
            self.indexLoadingState = .loading
            if self.state == .noResults {
                self.state = .loading
            }
        }
        if let response = try await APIClient.shared.retryWithExponentialDelay(task:{ try await APIClient.shared.getAllEvents(
            page: self.page,
            size: self.size,
            sortBy: self.sortBy,
            long: self.long,
            lat: self.lat,
            distance: Int32(self.distance),
            from: self.from,
            to: self.to,
            categories: self.categories
        )}) {
            
            DispatchQueue.main.async{
                
                let newPosts = response.data
                let existingPostIDs = Set(self.feedPosts.suffix(30).map { $0.id })
                let uniqueNewPosts = newPosts.filter { !existingPostIDs.contains($0.id) }
                
                self.feedPosts += uniqueNewPosts
                self.lastPage = response.lastPage
                
                self.page += 1
                
                self.feedPostsInit = false
                if response.listCount > 0 {
                    self.state = .loaded
                } else {
                    self.state = .noResults
                }
                self.indexLoadingState = .loaded
            }
        } else {
            DispatchQueue.main.async{
                self.state = .noResults
                self.indexLoadingState = .loaded
            }
        }
    }
    
    func feedScrollFetch(index: Int) {
        if !lastPage {
            if index == feedPosts.count - 7 && indexLoadingState == .loaded {
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
    
    func localRefreshEventOnAction(post: Components.Schemas.PostResponseDto){
        if let index = feedPosts.firstIndex(where: { $0.id == post.id }) {
            DispatchQueue.main.async{
                self.feedPosts[index] = post
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
    
    func postUpdateOnNewNotification(notification: Components.Schemas.NotificationDto) {
        if let not = notification.alertBodyAcceptedJoinRequest{
            if let post = not.post {
                if let index = self.feedPosts.firstIndex(where: {$0.id == post.id}){
                    self.feedPosts[index] = transferStatusDataFromMiniToNormalPost(miniPost: post, post: self.feedPosts[index])
                }
            }
        } else if let not = notification.alertBodyPostHasStarted {
            if let index = self.feedPosts.firstIndex(where: {$0.id == not.post.id}){
                self.feedPosts[index] = transferStatusDataFromMiniToNormalPost(miniPost: not.post, post: self.feedPosts[index])
            }
            
        } else if let not = notification.alertBodyReviewEndedPost {
            if let index = self.feedPosts.firstIndex(where: {$0.id == not.post.id}){
                self.feedPosts[index] = transferStatusDataFromMiniToNormalPost(miniPost: not.post, post: self.feedPosts[index])
            }
        }
        
    }
    
    func transferStatusDataFromMiniToNormalPost(miniPost: Components.Schemas.MiniPostDto, post:Components.Schemas.PostResponseDto) -> Components.Schemas.PostResponseDto {
        var newPost = post
        var currentUserStatus = miniPost.currentUserStatus.rawValue
        newPost.currentUserStatus = .init(rawValue: currentUserStatus) ?? post.currentUserStatus
        if let currentUserRole = miniPost.currentUserRole?.rawValue {
            newPost.currentUserRole = .init(rawValue: currentUserRole)
        }
        var status = miniPost.status.rawValue
        newPost.status = .init(rawValue: status) ?? post.status
        
        return newPost
    }
    
}
