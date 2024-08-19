//
//  ActivityViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 13.08.24.
//

import Foundation

class ActivityViewModel: ObservableObject {
    @Published var activityFeed: [Components.Schemas.ActivityDto] = []
    @Published var lastPage: Bool = true
    @Published var feedIsLoading: Bool = false
    @Published var feedInit: Bool = true
    @Published var page: Int32 = 0
    @Published var size: Int32 = 15
    
    @Published var state: LoadingCases = .loading
    
    func fetchFeed() async throws {
        DispatchQueue.main.async {
            if self.state == .noResults {
                self.state = .loading
            }
        }
        if let response = try await APIClient.shared.activityFeed(
            page: page,
            size: size
        ) {
            
            DispatchQueue.main.async {
                
                let newPosts = response.data
                let existingPostIDs = Set(self.activityFeed.suffix(30).map { $0.id })
                let uniqueNewPosts = newPosts.filter { !existingPostIDs.contains($0.id) }
                
                self.activityFeed += uniqueNewPosts
                self.lastPage = response.lastPage
                
                self.page += 1
                
                if response.listCount > 0 {
                    self.state = .loaded
                } else {
                    self.state = .noResults
                }
                self.feedInit = false
            }
        } else {
            self.state = .noResults
        }
    }
    
    func localRefreshEventOnAction(post: Components.Schemas.PostResponseDto){
        if let index = activityFeed.firstIndex(where: { $0.post?.id == post.id }) {
            DispatchQueue.main.async{
                self.activityFeed[index].post = post
            }
        }
        
    }
    
    func localRefreshClubOnAction(club: Components.Schemas.ClubDto){
        if let index = activityFeed.firstIndex(where: { $0.club?.id == club.id }) {
            DispatchQueue.main.async{
                self.activityFeed[index].club = club
            }
        }
    }
    
}
