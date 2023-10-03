//
//  UserViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 28.09.23.
//

import Foundation

class UserViewModel: ObservableObject {
    @Published var user: User = User.MOCK_USERS[0]
    
    func savePost(postId: String) {
        if !user.savedPosts.contains(postId){
            user.savedPosts.append(postId)
        } else {
            user.savedPosts.removeAll(where: { $0 == postId })
        }
    }
    
}
