//
//  HomeViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import Combine

//enum FeedItem: Hashable {
//    case event(Post)
//    case group(Club)
//}

enum SearchCases: Hashable {
    case events
    case users
    case clubs
    
    var toString: String {
        switch self {
        case .events:
            return "Events"
        case .users:
            return "Users"
        case .clubs:
            return "Clubs"
        }
    }
}

enum LoadingCases: Hashable {
    case loading
    case noResults
    case loaded
    case refresh
}

class HomeViewModel: ObservableObject {
    @Published var showSearch: Bool = false
    @Published var showCancelButton: Bool = false
    
    @Published var selectedFilter: SearchCases = .events {
        didSet{
//            self.searchText = ""
            self.toDefault()
            if !searchText.isEmpty{
                self.searchType()
            }
            
            
        }
    }

//    @Published var feedItems: [FeedItem] = []
//    
//    func fetchFeed() {
//        feedItems.append(contentsOf: Post.MOCK_POSTS.map { FeedItem.event($0) })
//        feedItems.append(contentsOf: Club.MOCK_CLUBS.map { FeedItem.group($0) })
//
//        feedItems.shuffle()
//    }
    
    
    @Published var searchText: String = ""
    var cancellable: AnyCancellable?
    @Published var searchedPosts: [Components.Schemas.PostResponseDto] = []
    @Published var searchedUsers: [Components.Schemas.MiniUser] = []
    @Published var searchedClubs: [Components.Schemas.ClubDto] = []

    @Published var lastSearchedPage: Bool = true
    @Published var searchedPage: Int32 = 0
    @Published var searchSize: Int32 = 15
    
    func searchPosts() async throws{
        Task{
            if let response = try await APIClient.shared.searchEvent(
                searchText: searchText,
                page: searchedPage,
                size: searchSize, 
                askToJoin: nil
            )
            {
                
                DispatchQueue.main.async { [weak self] in
                    self?.searchedPosts += response.data
                    self?.lastSearchedPage = response.lastPage
                    self?.searchedPage += 1
                }
            }
        }
    }
    
    func searchUsers() async throws{
        Task{
            if let response = try await APIClient.shared.searchUsers(
                searchText: searchText,
                page: searchedPage,
                size: searchSize)
            {
                
                DispatchQueue.main.async { [weak self] in
                    self?.searchedUsers += response.data
                    self?.lastSearchedPage = response.lastPage
                    self?.searchedPage += 1
                }
            }
        }
    }
    
    func searchClubs() async throws{
        Task{
            if let response = try await APIClient.shared.searchClubs(
                searchText: searchText,
                page: searchedPage,
                size: searchSize)
            {
                
                DispatchQueue.main.async { [weak self] in
                    self?.searchedClubs += response.data
                    self?.lastSearchedPage = response.lastPage
                    self?.searchedPage += 1
                }
            }
        }
    }
    
    func startSearch() {
        cancellable = $searchText
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { value in
                if !value.isEmpty {
                    print("Searching...")
                    self.toDefault()
                    self.searchType()
                    
                } else {
                    print("Not Searching...")
                    self.toDefault()
                }
            })
    }
    
    func searchType() {
        if self.selectedFilter == .events {
            Task{
                try await self.searchPosts()
            }
        } else if self.selectedFilter == .users {
            Task{
                try await self.searchUsers()
            }
        } else if self.selectedFilter == .clubs {
            Task{
                try await self.searchClubs()
            }
        }
    }
    
    func toDefault() {
        self.searchedPosts = []
        self.searchedUsers = []
        self.searchedClubs = []
        self.searchedPage = 0
        self.lastSearchedPage = true
    }
    
    func stopSearch() {
        cancellable = nil
        toDefault()
    }
    

    
}

struct HeaderBoundsKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>?
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = nextValue()
    }
}
