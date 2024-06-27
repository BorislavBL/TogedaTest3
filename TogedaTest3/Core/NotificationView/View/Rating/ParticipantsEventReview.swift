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
    @State var post: Components.Schemas.PostResponseDto = MockPost
    var createDate: Date
    
    var body: some View {
        VStack {
            if post.currentUserRole == .NORMAL {
                NavigationLink(value: SelectionPath.eventReview(post: post)){
                    frame()
                }
            } else {
                NavigationLink(value: SelectionPath.rateParticipants(post: post, rating: .init(value: Double(5), comment: nil))){
                    frame()
                }
            }

        }
        .onAppear(){
            Task{
                if let response = try await APIClient.shared.getEvent(postId: "9d42d204-ed18-4b19-b7cb-9a18df01e494") {
                    self.post = response
                }
            }
        }
    }
    
    func frame() -> some View{
        HStack {
            HStack(alignment:.top){
                KFImage(URL(string: alertBody.image))
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.dimension, height: size.dimension)
                    .cornerRadius(10)
                    .clipped()
            }
            
            VStack(alignment: .leading, spacing: 10){
                Text(alertBody.title)
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
    ParticipantsEventReview(alertBody: mockAlertBodyReviewEndedPost, createDate: Date())
}
