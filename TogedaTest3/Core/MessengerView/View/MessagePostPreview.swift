//
//  MessagePostPreview.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 22.11.23.
//

import SwiftUI

struct MessagePostPreview: View {
    let postID: String
    var post: Post? {
        let posts = Post.MOCK_POSTS
        return posts.first{ $0.id == postID}
    }
    
    var body: some View {

        VStack(alignment: .leading){
            if let post = post {
                NavigationLink(destination:EventView(viewModel: PostsViewModel(), post: post, userViewModel: UserViewModel())) {
                    VStack(alignment: .leading){
                        Image(post.imageUrl[0])
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width - 120, height: 220)
                            .clipped()
                        
                        HStack(spacing: 0){
                            Text(post.title)
                                .font(.callout)
                                .bold()
                                .lineLimit(2)
                            
                            Spacer(minLength: 10)
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                        .padding()
                    }
                }
            } else {
                ProgressView()
                .frame(width: UIScreen.main.bounds.width - 120, height: 250)
            }
        }
        .frame(width: UIScreen.main.bounds.width - 120)
        .background(Color("SecondaryBackground"))
        .cornerRadius(10)
        
    }
}

#Preview {
    MessagePostPreview(postID: Post.MOCK_POSTS[1].id)
}
