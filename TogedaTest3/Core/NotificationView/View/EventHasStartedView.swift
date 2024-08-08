//
//  EventHasStartedView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 7.08.24.
//

import SwiftUI
import Kingfisher

struct EventHasStartedView: View {
    let size: ImageSize = .medium
    var createDate: Date
    var alertBody: Components.Schemas.AlertBodyPostHasStarted
    @Binding var selectionPath: [SelectionPath]

    
    var body: some View {
            VStack {
                Button{
                    Task{
                        if let response = try await APIClient.shared.getEvent(postId: alertBody.post.id){
                            selectionPath.append(.eventDetails(response))
                        }
                    }
                } label:{
                    HStack(alignment:.top){
                        KFImage(URL(string: alertBody.post.images[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .cornerRadius(10)
                            .clipped()
                    }
                    
                    VStack(alignment: .leading, spacing: 5){
                        Text(alertBody.post.title)
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        Text("The event has started!")
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
    EventHasStartedView(createDate: Date(), alertBody: mockAlertBodyPostHasStartedRequest, selectionPath: .constant([]))
}
