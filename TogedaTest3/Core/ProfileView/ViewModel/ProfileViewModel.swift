//
//  ProfileViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation
import SwiftUI

class ProfileViewModel: ObservableObject {
//    @Published var posts = [Post]()
    
    @Published var tabIndex = 0
    @Published var offset: CGFloat = 2 * UIScreen.main.bounds.width
    @Published var rect: CGRect = .zero
    
//    let userr: User
//
//    init(userr: User) {
//        self.userr = userr
//        self.fetchUserPosts()
//    }
//
//    func fetchUserPosts() {
//        posts = PostService().fetchPosts(withIDs: userr.eventIDs)
//    }
//
    func changeView(left: Bool) {
        if left {
            if self.tabIndex != 4 {
                DispatchQueue.main.async {
                    withAnimation {
                        self.tabIndex += 1
                        self.offset = UIScreen.main.bounds.width * (2 - CGFloat(self.tabIndex))
                    }
                }
            }
        } else {
            if self.tabIndex != 0 {
                DispatchQueue.main.async {
                    withAnimation {
                        self.tabIndex -= 1
                        self.offset = UIScreen.main.bounds.width * (2 - CGFloat(self.tabIndex))
                    }
                }
            }
        }
    }
}


public struct ViewRectKey: PreferenceKey {
    public typealias Value = Array<CGRect>
    public static var defaultValue = [CGRect]()
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

