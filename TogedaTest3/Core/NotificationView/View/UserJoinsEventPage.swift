//
//  UserJoinsEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 11.12.24.
//

import SwiftUI
import Kingfisher

struct UserJoinsEventPage: View {
    let size: ImageSize = .medium
    var post: Components.Schemas.MiniPostDto
    var createDate: Date
    var alertBody: Components.Schemas.AlertBodyUserAddedToParticipants
    @Binding var selectionPath: [SelectionPath]

    var body: some View {
            VStack {
//                NavigationLink(value: SelectionPath.eventDetails(post)){
                Button{
                    Task{
                        if let response = try await APIClient.shared.getEvent(postId: post.id){
                            selectionPath.append(.eventDetails(response))
                        }
                    }
                } label:{
                    HStack(alignment:.top){
                        KFImage(URL(string:alertBody.userAdded.profilePhotos[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 5){
                        Text("\(alertBody.userAdded.firstName) \(alertBody.userAdded.lastName)")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        Text("Joined your event: \(post.title)")
                            .font(.footnote) +
                        
                        Text(" \(formatDateForNotifications(from: createDate))")
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
    UserJoinsEventPage(post: MockMiniPost, createDate: Date(), alertBody: mockAlertBodyUserAddedToParticipants, selectionPath: .constant([]))
}
