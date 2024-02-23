//
//  BookmarkedEventsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 12.01.24.
//

import SwiftUI

struct BookmarkedEventsView: View {
    var userID: String
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    @Environment(\.dismiss) var dismiss
    var posts: [Post]
    var body: some View {
        ScrollView{
            LazyVGrid(columns: columns){
                ForEach(posts){ post in
                    if post.hasEnded{
                        NavigationLink(value: SelectionPath.completedEventDetails(post)){
                            EventComponent(userID: userID, post: post)
                        }
                    } else {
                        NavigationLink(value: SelectionPath.eventDetails(post)){
                            EventComponent(userID: userID, post: post)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical)
        }
        .refreshable {
            
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Saved Events")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {dismiss()}) {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .background(.bar)
    }

}

#Preview {
    BookmarkedEventsView(userID: User.MOCK_USERS[0].id, posts: Post.MOCK_POSTS)
}
