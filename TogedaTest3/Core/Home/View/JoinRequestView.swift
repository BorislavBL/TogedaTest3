//
//  JoinRequestView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.10.23.
//

import SwiftUI

struct JoinRequestView: View {
    @EnvironmentObject var postsViewModel: PostsViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
    var post: Post? {
        return postsViewModel.posts.first(where: {$0.id == postsViewModel.clickedPostID})
    }
    
    var body: some View {
        if let post = post {
            VStack(spacing: 30){
                if let user = post.user, user.id == userId {
                    Text("How would you like to proceed?")
                        .font(.headline)
                        .fontWeight(.bold)
                } else {
                    if post.payment <= 0{
                        Text("Once you join you will be able to cancle it until 1h before the event starts. ")
                            .font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("No refunds.")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
                
                if post.date <= Date() {
                    if let user = post.user, user.id == userId{
                        
                        Button {
                            
                        } label: {
                            Text("Stop the Event")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .cornerRadius(10)
                        }
                        
                    }
                    else {
                        Button {
                            postsViewModel.likePost(postID: post.id, userID: userViewModel.user.id, user: userViewModel.user)
                            postsViewModel.showJoinRequest = false
                        } label: {
                            HStack(spacing:2){
                                if post.payment <= 0{
                                    if post.peopleIn.contains(userViewModel.user.id) {
                                        Image(systemName:"checkmark")
                                        Text("Joined")
                                            .fontWeight(.semibold)
                                    } else {
                                        Text("Join")
                                            .fontWeight(.semibold)
                                    }
                                } else {
                                    if post.peopleIn.contains(userViewModel.user.id) {
                                        Image(systemName:"checkmark")
                                        Text("Joined")
                                            .fontWeight(.semibold)
                                    } else {
                                        Text("Buy € \(String(format: "%.2f", post.payment))")
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                        }
                    }
                }
                else {
                    if let user = post.user, user.id == userId {
                        Button {
                            
                        } label: {
                            HStack(spacing:2){
                                Text("End the event")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                        }
                    } else {
                        Button {
                            
                        } label: {
                            HStack(spacing:2){
                                Text("Ongoing Event")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                        }
                    }
                }
            }
            .padding()
            .presentationDetents([.fraction(0.26)])
        }
    }
}

#Preview {
    JoinRequestView()
        .environmentObject(PostsViewModel())
        .environmentObject(UserViewModel())
}

