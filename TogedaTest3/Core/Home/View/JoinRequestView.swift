//
//  JoinRequestView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.10.23.
//

import SwiftUI

struct JoinRequestView: View {
    @ObservedObject var postsViewModel: PostsViewModel
    @ObservedObject var userViewModel: UserViewModel
    let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
    var body: some View {
        VStack(spacing: 30){
            if let user = postsViewModel.posts[postsViewModel.clickedPostIndex].user, user.id == userId {
                Text("How would you like to proceed?")
                    .font(.headline)
                    .fontWeight(.bold)
            } else {
                if postsViewModel.posts[postsViewModel.clickedPostIndex].payment <= 0{
                    Text("Once you join you will be able to cancle it until 1h before the event starts. ")
                        .font(.headline)
                        .fontWeight(.bold)
                } else {
                    Text("No refunds.")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            
            if postsViewModel.posts[postsViewModel.clickedPostIndex].date <= Date() {
                if let user = postsViewModel.posts[postsViewModel.clickedPostIndex].user, user.id == userId{
                    
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
                        postsViewModel.likePost(postID: postsViewModel.posts[postsViewModel.clickedPostIndex].id, userID: userViewModel.user.id, user: userViewModel.user)
                        postsViewModel.showJoinRequest = false
                    } label: {
                        HStack(spacing:2){
                            if postsViewModel.posts[postsViewModel.clickedPostIndex].payment <= 0{
                                if postsViewModel.posts[postsViewModel.clickedPostIndex].peopleIn.contains(userViewModel.user.id) {
                                    Image(systemName:"checkmark")
                                    Text("Joined")
                                        .fontWeight(.semibold)
                                } else {
                                    Text("Join")
                                        .fontWeight(.semibold)
                                }
                            } else {
                                if postsViewModel.posts[postsViewModel.clickedPostIndex].peopleIn.contains(userViewModel.user.id) {
                                    Image(systemName:"checkmark")
                                    Text("Joined")
                                        .fontWeight(.semibold)
                                } else {
                                    Text("Buy € \(String(format: "%.2f", postsViewModel.posts[postsViewModel.clickedPostIndex].payment))")
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
                if let user = postsViewModel.posts[postsViewModel.clickedPostIndex].user, user.id == userId {
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
        .presentationDetents([.fraction(0.2)])
    }
}

#Preview {
    JoinRequestView(postsViewModel: PostsViewModel(), userViewModel: UserViewModel())
}

