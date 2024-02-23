//
//  EventAcceptance.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 8.11.23.
//

import SwiftUI

struct EventAcceptance: View {
    let size: ImageSize = .medium
    var post: Post = Post.MOCK_POSTS[2]
    @EnvironmentObject var postsVM: PostsViewModel
    var body: some View {
            VStack {
                NavigationLink(value: SelectionPath.eventDetails(post)){
                    HStack(alignment:.top){
                        Image(post.imageUrl[0])
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .cornerRadius(10)
                            .clipped()
                    }
                    
                    VStack(alignment: .leading, spacing: 5){
                        Text(post.title)
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        Text("You got accepted. Visit the event page for more details.")
                            .font(.footnote) +
                        
                        Text(" 1 min ago")
                            .foregroundStyle(.gray)
                            .font(.footnote)
                        
                        
                    }
                    .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                    
                }
                
            }
    }
}

#Preview {
    EventAcceptance()
        .environmentObject(PostsViewModel())
}
