//
//  PostsViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation
import Combine
import MapKit

@MainActor
class PostsViewModel: ObservableObject {
//    @Published var posts: [Post] = Post.MOCK_POSTS

    @Published var clickedPostIndex: Int = 0
    @Published var clickedPostID: String = Post.MOCK_POSTS[1].id
    
    @Published var showDetailsPage = false
    @Published var showPostOptions = false
    @Published var selectedOption = "None"
    @Published var showJoinRequest = false
    @Published var isLoading: Bool = false
    
    @Published var showSharePostSheet: Bool = false
    
//    func likePost(postID: String, userID: String, user: User) {
//        let miniUser = MiniUser(id: user.id, firstName: user.firstName, lastName: user.lastName, birthDate: user.birthDate, profilePhotos: user.profilePhotos, occupation: user.occupation, location: user.location)
//        if let index = posts.firstIndex(where: { $0.id == postID }) {
//            if !posts[index].peopleIn.contains(userID){
//                posts[index].peopleIn.append(userID)
//            } else {
//                posts[index].peopleIn.removeAll(where: { $0 == userID })
//            }
//            
//            if !posts[index].participants.contains(miniUser){
//                posts[index].participants.append(miniUser)
//            } else {
//                posts[index].participants.removeAll(where: { $0 == miniUser })
//            }
//        }
//        
//    }
    
    
    //Monolith implementation
    @Published var feedPosts: [Components.Schemas.PostResponseDto] = []
    @Published var lastPage: Bool = false
    
    @Published var page: Int32 = 0
    @Published var size: Int32 = 15
    @Published var lat: Double = 43
    @Published var long: Double = 39
    @Published var distance: Int = 300
    @Published var from: Date? = nil
    @Published var to: Date? = nil
    
    private var locationCancellables = Set<AnyCancellable>()
    private var locationManager = LocationManager()
    
    init() {
        locationManager.$location
            .compactMap { $0 } // Ensure the location is not nil
            .first() // Take only the first non-nil location
            .sink { [weak self] location in
                guard let self = self else { return }
                self.lat = location.coordinate.latitude
                self.long = location.coordinate.longitude
                Task {
                    try await self.fetchPosts()
                }
            }
            .store(in: &locationCancellables)
    }
    
    func applyFilter(lat: Double, long: Double, distance: Int, from: Date?, to: Date?) async throws {
        page = 0
        feedPosts = []
        
        self.lat = lat
        self.long = long
        self.distance = distance
        self.from = from
        self.to = to
        
        Task{
           try await self.fetchPosts()
        }
    }
    
    func fetchPosts() async throws {
        if let response = try await APIClient.shared.getAllEvents(
            page: page,
            size: size,
            long: long,
            lat: lat,
            distance: Int32(distance),
            from: from,
            to: to) {

            feedPosts += response.data
            lastPage = response.lastPage
            page += 1
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
    
    @Published var searchText: String = ""
    var cancellable: AnyCancellable?
    
    func startSearch() {
        cancellable = $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { value in
                if !value.isEmpty {
                    print("Searching...")
                } else {
                    print("Not Searching...")
                }
            })
    }
    
    func stopSearch() {
        cancellable = nil
    }
    
}
