//
//  AllGroupEventsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 22.01.24.
//

import SwiftUI

struct AllGroupEventsView: View {
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
                    if post.hasEnded {
                        NavigationLink(destination: CompletedEventView(postID: post.id)){
                            GroupEventComponent(post: post)
                        }
                    } else {
                        NavigationLink(destination: EventView(postID: post.id)){
                            GroupEventComponent(post: post)
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
        .navigationTitle("Events")
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
    AllGroupEventsView(posts: Post.MOCK_POSTS)
}
