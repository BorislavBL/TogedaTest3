//
//  PostTags.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import WrappingHStack

struct PostTags: View {
    @State private var showMoreTags = false
    
    @EnvironmentObject var viewModel: PostsViewModel
    var post: Post
    
    var body: some View {
        WrappingHStack(alignment: .leading, horizontalSpacing: 5) {
            
//            HStack(spacing: 3) {
//                Image(systemName: "wallet.pass")
//                Text("Event")
//                    .normalTagTextStyle()
//
//            }
//            .normalTagCapsuleStyle()
            
            HStack(spacing: 3) {
                Image(systemName: "wallet.pass")
                if post.payment <= 0{
                    Text("Free")
                        .normalTagTextStyle()
                } else {
                    Text("€\(String(format:"%.2f", post.payment))")
                        .normalTagTextStyle()
                }
            }
            .normalTagCapsuleStyle()
            
            HStack(spacing: 3) {
                Image(systemName: "calendar")
                Text(separateDateAndTime(from: post.date).date)
                    .normalTagTextStyle()
            }
            .normalTagCapsuleStyle()
            
            HStack(spacing: 3) {
                Image(systemName: "clock")
                Text(separateDateAndTime(from: post.date).time)
                    .normalTagTextStyle()
            }
            .normalTagCapsuleStyle()
            
            HStack(spacing: 3) {
                Image(systemName: "globe.europe.africa.fill")
                if post.askToJoin {
                    Text("Ask to join")
                        .normalTagTextStyle()
                } else {
                    Text(post.accessability.value)
                        .normalTagTextStyle()
                }
            }
            .normalTagCapsuleStyle()
            
            if let city = post.location.city{
                
                HStack(spacing: 3) {
                    Image(systemName: "location")
                    Text(city)
                        .normalTagTextStyle()
                }
                .normalTagCapsuleStyle()
            }
            
            
            HStack(spacing: 3) {
                Image(systemName: "person.3")
                Text("\(post.peopleIn.count)/\(post.maximumPeople)")
                    .normalTagTextStyle()
            }
            .normalTagCapsuleStyle()
            HStack(spacing: 3) {
                Image(systemName: "square.grid.2x2")
                Text(post.category)
                    .normalTagTextStyle()
            }
            .normalTagCapsuleStyle()

        }
    }
}

struct PostTags_Previews: PreviewProvider {
    static var previews: some View {
        PostTags(post: Post.MOCK_POSTS[0])
            .environmentObject(PostsViewModel())
    }
}


