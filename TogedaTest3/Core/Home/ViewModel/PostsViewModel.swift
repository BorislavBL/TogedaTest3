//
//  PostsViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation
import CoreLocation

class PostsViewModel: ObservableObject {
    @Published var posts: [Post] = Post.MOCK_POSTS
    
    @Published var expandedTags: [String: Bool] = [:] // Local state for tags expansion

    @Published var clickedPostIndex: Int = 0
    @Published var clickedPostID: String = Post.MOCK_POSTS[1].id
    
    @Published var showDetailsPage = false
    @Published var showPostOptions = false
    @Published var selectedOption = "None"
    @Published var showJoinRequest = false
    @Published var isLoading: Bool = false

    func fetchPosts() {
        DispatchQueue.main.async {
            for post in self.posts {
                self.expandedTags[post.id] = false
            }
        }
    }
    
    func toggleTagsExpansion(for postId: String) {
        expandedTags[postId]?.toggle()
    }
    
    
    func likePost(postID: String, userID: String, user: User) {
        let miniUser = MiniUser(id: user.id, username: user.username,profileImageUrl: user.profileImageUrl, from: user.from ,fullname: user.fullname, title: user.title)
        if let index = posts.firstIndex(where: { $0.id == postID }) {
            if !posts[index].peopleIn.contains(userID){
                posts[index].peopleIn.append(userID)
            } else {
                posts[index].peopleIn.removeAll(where: { $0 == userID })
            }
            
            if !posts[index].participants.contains(miniUser){
                posts[index].participants.append(miniUser)
            } else {
                posts[index].participants.removeAll(where: { $0 == miniUser })
            }
        }
        
    }
    
}
