//
//  EventComponent.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct EventComponent: View {
    var post: Post
    private let imageDimension: CGFloat = (UIScreen.main.bounds.width / 3) - 18
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(post.imageUrl[0])
                .resizable()
                .scaledToFill()
                .frame(width: imageDimension, height: imageDimension * 1.3)
                .clipped()
            
            VStack{
                Text(post.title)
                    .font(.footnote)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: imageDimension)
            .frame(height: imageDimension * 0.4)
            .background(Color(.black).opacity(0.3))
        }
        .cornerRadius(20)
    }
}

struct EventComponent_Previews: PreviewProvider {
    static var previews: some View {
        EventComponent(post: Post.MOCK_POSTS[0])
    }
}
