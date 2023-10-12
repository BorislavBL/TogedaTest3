//
//  EventMapPreview.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.10.23.
//

import SwiftUI
import MapKit

struct EventMapPreview: View {
    let post: Post
    var address: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            HStack(alignment:.top, spacing: 10){
                Image(post.imageUrl)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height:80)
                    .cornerRadius(10)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 8){
                    Text(post.title)
                        .font(.body)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    HStack(alignment: .center, spacing: 10) {
                        HStack(alignment: .center, spacing: 5) {
                            Text("\(separateDateAndTime(from: post.date).weekday), \(separateDateAndTime(from: post.date).date)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                            
                            Text("at \(separateDateAndTime(from: post.date).time)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                        }
                    }
                    
                    Text(address ?? "")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            Spacer()
            
            HStack(spacing: 30) {
                HStack(spacing: 3) {
                    Image(systemName: "person.3")
                        .foregroundStyle(.gray)
                    Text("\(post.peopleIn.count)/\(post.maximumPeople)")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.leading)
                    
                }
                
                HStack(spacing: 3) {
                    Image(systemName: "wallet.pass")
                        .foregroundStyle(.gray)
                    if post.payment <= 0 {
                        Text("Free")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("$ \(String(format: "%.2f", post.payment))")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.leading)
                    }
                    
                }
                
                Spacer()
                
                Image(systemName: "chevron.right.2")
                    .foregroundStyle(.gray)
                
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}

#Preview {
    EventMapPreview(post: Post.MOCK_POSTS[0])
}
