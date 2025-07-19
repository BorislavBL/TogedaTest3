//
//  UserJoinsClubPage.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 11.12.24.
//

import SwiftUI
import Kingfisher

struct UserJoinsClubPage: View {
    let size: ImageSize = .medium
    var club: Components.Schemas.MiniClubDto
    var createDate: Date
    var alertBody: Components.Schemas.AlertBodyUserAddedToParticipants
    @Binding var selectionPath: [SelectionPath]
    
    var body: some View {
        HStack {
            //                NavigationLink(value: SelectionPath.club(club)){
            NavigationLink(value: SelectionPath.profile(alertBody.userAdded)) {
                KFImage(URL(string:alertBody.userAdded.profilePhotos[0]))
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.dimension, height: size.dimension)
                    .clipShape(Circle())
            }
            
            Button{
                Task{
                    if let response = try await APIClient.shared.getClub(clubID: club.id){
                        selectionPath.append(.club(response))
                    }
                }
            } label:{
                VStack(alignment: .leading, spacing: 5){
                    Text("\(alertBody.userAdded.firstName) \(alertBody.userAdded.lastName)")
                        .font(.footnote)
                        .fontWeight(.semibold)
                    
                    Text("Joined your club: \(club.title)")
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
    UserJoinsClubPage(club: MockMiniClub, createDate: Date(), alertBody: mockAlertBodyUserAddedToParticipants, selectionPath: .constant([]))
}
