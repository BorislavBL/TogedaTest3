//
//  ProfileViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var showImageSet: Bool = false
    @Published var selectedPost: Post = Post.MOCK_POSTS[0]
    @Published var showCompletedEvent: Bool = false
    
    
}


