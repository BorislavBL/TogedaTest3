//
//  PostCell.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import WrappingHStack

struct PostCell: View {
    @ObservedObject var viewModel: PostsViewModel
    var post: Post
    
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 15){
                
                //MARK: - Post Header
                
                HStack(alignment: .center) {
                    HStack(alignment:.center) {
                        if let user = post.user{
                            NavigationLink(value: user) {
                                if let image = user.profileImageUrl {
                                    Image(image[0])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .background(.gray)
                                        .cornerRadius(20)
                                    
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 3){
                                Text(post.title)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                Text(user.fullname)
                                    .foregroundColor(.gray)
                                    .fontWeight(.semibold)
                                    .font(.footnote)
                            }
                        }
                        

                    }
                    
                    Spacer()
                    
                    //MARK: - Post Options
                    
                    Button {
                        viewModel.showPostOptions = true
                        viewModel.clickedPostIndex = viewModel.posts.firstIndex(of: post) ?? 0
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                    }

                    
                    
                }
                
//                NavigationLink(value: post) {
//                    TabView {
//                        ForEach(1...3, id: \.self) { number in
//                            Image("event_\(number)")
//                                .resizable()
//                                .scaledToFill()
//                                .clipped()
//
//                        }
//
//                    }
//                    .background(.gray)
//                    .tabViewStyle(PageTabViewStyle())
//                    .cornerRadius(10)
//                    .frame(height: 300)
//                }
                
                
                Button(action: {
                    viewModel.showDetailsPage = true
                    viewModel.clickedPostIndex = viewModel.posts.firstIndex(of: post) ?? 0
                }, label: {
                    Image(post.imageUrl[0])
                        .resizable()
                        .scaledToFill()
                        .frame(maxHeight: 400)
                        .cornerRadius(10)
                })
                
//                NavigationLink(value: post) {
//                    Image(post.imageUrl)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(maxHeight: 400)
//                        .cornerRadius(10)
//                }

                //MARK: - Buttons
                
                HStack(alignment: .center, spacing: 20){
                    Button {
//                        viewModel.likePost(postID: post.id, userID: userViewModel.user.id, user: userViewModel.user)
                        viewModel.clickedPostIndex = viewModel.posts.firstIndex(of: post) ?? 0
                        viewModel.showJoinRequest = true
                    } label: {
                        Image(systemName: post.peopleIn.contains(userViewModel.user.id) ? "person.2.circle.fill" : "person.2.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    
                    if post.peopleIn.contains(userViewModel.user.id) || post.accessability == .Public{
                        
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
                        print("Send")
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
                PostTags(viewModel: viewModel, post: post)
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
        PostCell(viewModel: PostsViewModel(), post: Post.MOCK_POSTS[0], userViewModel: UserViewModel())
    }
}
