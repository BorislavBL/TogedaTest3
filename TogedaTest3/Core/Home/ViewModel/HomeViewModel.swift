//
//  HomeViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

enum FeedItem: Hashable {
    case event(Post)
    case group(Club)
}

class HomeViewModel: ObservableObject {
    @Published var showSearch: Bool = false
    @Published var showCancelButton: Bool = false
    
    @Published var selectedFilter = searchFilters[0]
    @Published var searchPostResults: [Post] = Post.MOCK_POSTS
    @Published var searchUserResults: [MiniUser] = MiniUser.MOCK_MINIUSERS

    @Published var feedItems: [FeedItem] = []
    
    func fetchFeed() {
        feedItems.append(contentsOf: Post.MOCK_POSTS.map { FeedItem.event($0) })
        feedItems.append(contentsOf: Club.MOCK_CLUBS.map { FeedItem.group($0) })

        feedItems.shuffle()
    }
    

    
}

struct HeaderBoundsKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>?
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = nextValue()
    }
}
