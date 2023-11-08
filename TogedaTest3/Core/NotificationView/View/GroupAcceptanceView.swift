//
//  GroupAcceptanceView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 8.11.23.
//

import SwiftUI

struct GroupAcceptanceView: View {
    let size: ImageSize = .medium
    var post: Post = Post.MOCK_POSTS[0]
    var body: some View {
        VStack {
            NavigationLink(destination: EventView(viewModel: PostsViewModel(), post: post, userViewModel: UserViewModel())){
                HStack(alignment:.top){
                        Image(post.imageUrl[0])
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 5){
                    Text(post.title)
                        .font(.footnote)
                        .fontWeight(.semibold)
                    
                    Text("You got accepted.")
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
    GroupAcceptanceView()
}
