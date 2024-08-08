//
//  GroupAcceptanceView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 8.11.23.
//

import SwiftUI
import Kingfisher

struct GroupAcceptanceView: View {
    let size: ImageSize = .medium
    var club: Components.Schemas.MiniClubDto
    var createDate: Date
    var alertBody: Components.Schemas.AlertBodyAcceptedJoinRequest
    @Binding var selectionPath: [SelectionPath]
    
    var body: some View {
        VStack {
            /*NavigationLink(value: SelectionPath.club(club))*/
            Button{
                Task{
                    if let response = try await APIClient.shared.getClub(clubID: club.id){
                        selectionPath.append(.club(response))
                    }
                }
            } label:{
                HStack(alignment:.top){
                    KFImage(URL(string:club.images[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 5){
                    Text(club.title)
                        .font(.footnote)
                        .fontWeight(.semibold)
                    
                    Text("You got accepted.")
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
    GroupAcceptanceView(club: MockMiniClub, createDate: Date(), alertBody: mockAlertBodyAcceptedJoinRequest, selectionPath: .constant([]))
}
