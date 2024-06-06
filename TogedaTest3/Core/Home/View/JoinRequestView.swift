//
//  JoinRequestView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.10.23.
//

import SwiftUI

struct JoinRequestView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var postsViewModel: PostsViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var post: Components.Schemas.PostResponseDto
    
    var body: some View {
        VStack(spacing: 30){
            if isOwner {
                Text("How would you like to proceed?")
                    .font(.headline)
                    .fontWeight(.bold)
            } else {
                if post.payment <= 0 {
                    Text("Once you join you will be able to cancle it until 1h before the event starts.")
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                } else {
                    Text("No refunds within the day of the event.")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            
            if isOwner {
                if post.status == .HAS_STARTED {
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
                } else if post.status == .NOT_STARTED {
                    if post.fromDate != nil {
                        Button {
                            
                        } label: {
                            Text("End the Event")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .cornerRadius(10)
                        }
                    } else {
                        Button {
                            
                        } label: {
                            Text("Start the Event")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .cornerRadius(10)
                        }
                    }
                }
                
            } else {
                if post.status == .HAS_STARTED {
                    Button {
                        
                    } label: {
                        Text("Ongoing")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                    }
                } else if post.status == .NOT_STARTED {
                    if post.currentUserStatus == .PARTICIPATING {
                        Button {
                            
                        } label: {
                            Text("Leave")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .cornerRadius(10)
                        }
                    } else if post.currentUserStatus == .IN_QUEUE {
                        Button {
                            
                        } label: {
                            Text("Waiting")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .cornerRadius(10)
                        }
                    } else {
                        Button {
                            Task{
                                if try await APIClient.shared.joinEvent(postId: post.id) != nil {
                                    if let response = try await APIClient.shared.getEvent(postId: post.id){
                                        try await postsViewModel.refreshEventOnAction(postId: post.id)
                                        post = response
                                    }
                                }
                            }
                        } label: {
                            Text("Join")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .cornerRadius(10)
                        }
                    }
                    
                }
            }
            
        }
        .padding()
        .presentationDetents([.fraction(0.26)])
    }
    
    var isOwner: Bool {
        if let user = userViewModel.currentUser, user.id == post.owner.id{
            return true
        } else {
            return false
        }
    }
}

#Preview {
    JoinRequestView(post: .constant(MockPost))
        .environmentObject(PostsViewModel())
        .environmentObject(UserViewModel())
}

