//
//  HomeViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation

import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var showSearch: Bool = false
    @Published var showCancelButton: Bool = false
    
    @Published var selectedFilter = searchFilters[0]
    @Published var searchPostResults: [Post] = Post.MOCK_POSTS
    @Published var searchUserResults: [MiniUser] = MiniUser.MOCK_MINIUSERS
    
}

struct HeaderBoundsKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>?
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = nextValue()
    }
}
