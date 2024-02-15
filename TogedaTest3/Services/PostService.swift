//
//  PostService.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation

class PostService {
    func fetchPost(withID id: String) {
        
    }
    
    func fetchPosts(withIDs ids: [String]) -> [Post] {
        return Post.MOCK_POSTS.filter { post in
            return ids.contains(post.id)
        }
    }
}
