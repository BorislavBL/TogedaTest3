//
//  ParticipantsEventReview.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.11.23.
//

import SwiftUI

struct ParticipantsEventReview: View {
    let size: ImageSize = .medium
    var post: Post = Post.MOCK_POSTS[0]
    var body: some View {
        VStack {
            NavigationLink(value: SelectionPath.eventReview){
                HStack(alignment:.top){
                        Image(post.imageUrl[0])
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .cornerRadius(10)
                            .clipped()
                }
                
                VStack(alignment: .leading, spacing: 10){
                    Text(post.title)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 2){
                        Text("Review · ")
                            .foregroundStyle(.gray)
                            .font(.footnote)
                    ForEach(0..<5, id: \.self) { i in

                            Image(systemName: "star.fill")
                                .foregroundStyle(.gray)
                                .imageScale(.small)
                        }
                    }
                }
                Spacer(minLength: 0)
                
                Image(systemName: "chevron.right")
            
            }
            
        }
    }
}
#Preview {
    ParticipantsEventReview()
}
