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
    
    @ObservedObject var viewModel: PostsViewModel
    var post: Post
    
    var body: some View {
        WrappingHStack(alignment: .leading, horizontalSpacing: 5) {
            
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
                Image(systemName: "location")
                Text("10km")
                    .normalTagTextStyle()
            }
            .normalTagCapsuleStyle()
            
            
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
            
            if(viewModel.expandedTags[post.id] == true){
                ForEach(post.interests, id: \.self) { interest in
                    Text(interest)
                        .normalTagTextStyle()
                        .normalTagCapsuleStyle()
                }
            }
            
            Button {
                DispatchQueue.main.async {
                    withAnimation {
                        viewModel.toggleTagsExpansion(for: post.id)
                    }
                }
                
            } label: {
                if(viewModel.expandedTags[post.id] == true){
                    Text("Less")
                        .selectedTagTextStyle()
                        .selectedTagCapsuleStyle()
                } else {
                    Text("More")
                        .normalTagTextStyle()
                        .normalTagCapsuleStyle()
                }
            }

        }
    }
}

struct PostTags_Previews: PreviewProvider {
    static var previews: some View {
        PostTags(viewModel: PostsViewModel(), post: Post.MOCK_POSTS[0])
    }
}


