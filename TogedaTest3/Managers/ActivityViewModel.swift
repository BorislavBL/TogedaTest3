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
    
    func fetchFeed() async throws {
        DispatchQueue.main.async {
            self.feedIsLoading = true
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
                
                self.feedIsLoading = false
                self.feedInit = false
            }
        }
    }
}
