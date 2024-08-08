//
//  MessagePostPreview.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 22.11.23.
//

import SwiftUI
import Kingfisher

struct MessagePostPreview: View {
    let postID: String
    @State var post: Components.Schemas.PostResponseDto?
    
    var body: some View {
        VStack(alignment: .leading){
            if let post = post {
                NavigationLink(value: SelectionPath.eventDetails(post)) {
                    VStack(alignment: .leading){
                        KFImage(URL(string: post.images[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width - 120, height: 220)
                            .clipped()
                        
                        HStack(spacing: 0){
                            Text(post.title)
                                .font(.callout)
                                .bold()
                                .lineLimit(2)
                            
                            Spacer(minLength: 10)
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                        .padding()
                    }
                }
            } else {
                ProgressView()
                .frame(width: UIScreen.main.bounds.width - 120, height: 250)
            }
        }
        .frame(width: UIScreen.main.bounds.width - 120)
        .background(Color("SecondaryBackground"))
        .cornerRadius(10)
        .onAppear(){
            Task{
                self.post = try await APIClient.shared.getEvent(postId: postID)
            }
        }
        
    }
}

#Preview {
    MessagePostPreview(postID: "")
}
