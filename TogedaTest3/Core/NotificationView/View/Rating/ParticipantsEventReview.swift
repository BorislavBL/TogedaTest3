//
//  ParticipantsEventReview.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.11.23.
//

import SwiftUI
import Kingfisher

struct ParticipantsEventReview: View {
    let size: ImageSize = .medium
    var alertBody: Components.Schemas.AlertBodyReviewEndedPost
    var createDate: Date
    @Binding var selectionPath: [SelectionPath]
    
    var body: some View {
        VStack {
            if alertBody.post.currentUserRole == .NORMAL {
//                NavigationLink(value: SelectionPath.eventReview(post: alertBody.post))
                Button{
                    Task{
                        if let response = try await APIClient.shared.getEvent(postId: alertBody.post.id){
                            selectionPath.append(.eventReview(post: response))
                        }
                    }
                } label:
                {
                    frame()
                }
            } else {
//                NavigationLink(value: SelectionPath.rateParticipants(post: alertBody.post, rating: .init(value: Double(5), comment: nil)))
                Button{
                    Task{
                        if let response = try await APIClient.shared.getEvent(postId: alertBody.post.id){
                            selectionPath.append(.rateParticipants(post: response, rating: .init(value: Double(5), comment: nil)))
                        }
                    }
                } label:
                {
                    frame()
                }
            }
            
        }
    }
    
    func frame() -> some View{
        HStack {
            HStack(alignment:.top){
                KFImage(URL(string: alertBody.post.images[0]))
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.dimension, height: size.dimension)
                    .cornerRadius(10)
                    .clipped()
            }
            
            VStack(alignment: .leading, spacing: 10){
                Text(alertBody.post.title)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 2){
                    Text("Review · ")
                        .foregroundStyle(.gray)
                        .font(.footnote)
                    
                    
                    ForEach(0..<5, id: \.self) { i in
                        
                        Image(systemName: "star.fill")
                            .foregroundStyle(.gray)
                            .imageScale(.small)
                    }
                    
                }
            }
            Spacer(minLength: 0)
            
            Image(systemName: "chevron.right")
            
        }
    }
}

#Preview {
    ParticipantsEventReview(alertBody: mockAlertBodyReviewEndedPost, createDate: Date(), selectionPath: .constant([]))
}
