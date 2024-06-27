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
    @State var post: Components.Schemas.PostResponseDto = MockPost
    var createDate: Date
    var alertBody: Components.Schemas.AlertBodyReceivedJoinRequest
    
    var body: some View {
            VStack {
                NavigationLink(value: SelectionPath.eventDetails(post)){
                    HStack(alignment:.top){
                        KFImage(URL(string:alertBody.image))
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .cornerRadius(10)
                            .clipped()
                    }
                    
                    VStack(alignment: .leading, spacing: 5){
                        Text(alertBody.title)
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
    EventRequestPage(createDate: Date(), alertBody: mockAlertBodyReceivedJoinRequest)
}
