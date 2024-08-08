//
//  EventRequestPage.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 22.01.24.
//

import SwiftUI
import Kingfisher

struct EventRequestPage: View {
    let size: ImageSize = .medium
    var post: Components.Schemas.MiniPostDto
    var createDate: Date
    var alertBody: Components.Schemas.AlertBodyReceivedJoinRequest
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
                        KFImage(URL(string:post.images[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .cornerRadius(10)
                            .clipped()
                    }
                    
                    VStack(alignment: .leading, spacing: 5){
                        Text(post.title)
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        Text("Someone wants to join your event.")
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
    EventRequestPage(post: MockMiniPost, createDate: Date(), alertBody: mockAlertBodyReceivedJoinRequest, selectionPath: .constant([]))
}
