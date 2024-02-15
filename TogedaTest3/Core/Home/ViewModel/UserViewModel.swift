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
        if !user.details.savedPostIds.contains(postId){
            user.details.savedPostIds.append(postId)
        } else {
            user.details.savedPostIds.removeAll(where: { $0 == postId })
        }
    }
    
}
