//
//  PostCell.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import WrappingHStack

struct PostCell: View {
    @EnvironmentObject var viewModel: PostsViewModel
    var post: Post
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 15){
                
                //MARK: - Post Header
                
                HStack(alignment: .center) {

                        if let user = post.user{
                            NavigationLink(value: user) {
                                
                                Image(user.profileImageUrl[0])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .background(.gray)
                                    .cornerRadius(15)
                            }
                            
                            VStack(alignment: .leading, spacing: 3){
                                Text(post.title)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                Text(user.fullName)
                                    .foregroundColor(.gray)
                                    .fontWeight(.semibold)
                                    .font(.footnote)
                            }
                        
                        
                        
                    }
                    
                    Spacer()
                    
                    //MARK: - Post Options
                    
                    Button {
                        viewModel.showPostOptions = true
                        viewModel.clickedPostID = post.id
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                    }
   
                }
 
                NavigationLink(value: post) {
                    Image(post.imageUrl[0])
                        .resizable()
                        .scaledToFill()
                        .frame(maxHeight: 400)
                        .cornerRadius(10)
                }
                
                //MARK: - Buttons
                
                HStack(alignment: .center, spacing: 20){
                    Button {
                        viewModel.clickedPostID = post.id
                        viewModel.showJoinRequest = true
                    } label: {
                        Image(systemName: post.peopleIn.contains(userViewModel.user.id) ? "person.2.circle.fill" : "person.2.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    
                    if post.peopleIn.contains(userViewModel.user.id) || !post.askToJoin{
                        
                        Button{
                            let url = URL(string: "maps://?saddr=&daddr=\(post.location.latitude),\(post.location.longitude)")
                            if UIApplication.shared.canOpenURL(url!) {
                                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                            }
                        } label: {
                            Image(systemName: "mappin.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                        }
                    } else {
                        Image(systemName: "mappin.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.gray)
                    }
                    
                    Button {
                        viewModel.clickedPostID = post.id
                        viewModel.showSharePostSheet = true
                    } label: {
                        
                        Image(systemName: "paperplane")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    
                    Spacer()
                    
                    Button {
                        userViewModel.savePost(postId: post.id)
                    } label: {
                        Image(systemName: userViewModel.user.savedPosts.contains(post.id) ? "bookmark.fill" : "bookmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    
                }
                .foregroundColor(Color("textColor"))
                
                //MARK: - Tags
                PostTags(post: post)
            }
            
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color("postCellColor"))
        .cornerRadius(10)
        .padding(.horizontal, 8)
    }
}

struct PostCell_Previews: PreviewProvider {
    static var previews: some View {
        PostCell(post: Post.MOCK_POSTS[1])
            .environmentObject(PostsViewModel())
            .environmentObject(UserViewModel())
    }
}
