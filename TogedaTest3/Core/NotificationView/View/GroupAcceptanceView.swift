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
    @State var club: Components.Schemas.ClubDto = MockClub
    var createDate: Date
    var alertBody: Components.Schemas.AlertBodyAcceptedJoinRequest
    
    var body: some View {
        VStack {
            NavigationLink(value: SelectionPath.club(club)){
                HStack(alignment:.top){
                    KFImage(URL(string:alertBody.image))
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 5){
                    Text(alertBody.title)
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
    GroupAcceptanceView(createDate: Date(), alertBody: mockAlertBodyAcceptedJoinRequest)
}
