//
//  EventAcceptance.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 8.11.23.
//

import SwiftUI
import Kingfisher

struct EventAcceptance: View {
    let size: ImageSize = .medium
    @State var post: Components.Schemas.PostResponseDto = MockPost
    var createDate: Date
    var alertBody: Components.Schemas.AlertBodyAcceptedJoinRequest
    
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
                        
                        Text("You got accepted. Visit the event page for more details.")
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
    EventAcceptance(createDate: Date(), alertBody: mockAlertBodyAcceptedJoinRequest)
}
