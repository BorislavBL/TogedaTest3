//
//  ClubEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.01.25.
//

import SwiftUI
import Kingfisher

struct ClubEventView: View {
    let size: ImageSize = .medium
    var post: Components.Schemas.MiniPostDto
    var club: Components.Schemas.MiniClubDto
    var createDate: Date
    var alertBody: Components.Schemas.AlertBodyPostWasCreatedInClub
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
                    KFImage(URL(string: post.images[0]))
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
                    
                    Text("A new event has been added to the ")
                        .font(.footnote) +
                    
                    Text("\(club.title) club.")
                        .fontWeight(.semibold)
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
    ClubEventView(post: MockMiniPost, club: MockMiniClub, createDate: Date(), alertBody: mockAlertBodyPostWasCreatedInClub, selectionPath: .constant([]))
}
