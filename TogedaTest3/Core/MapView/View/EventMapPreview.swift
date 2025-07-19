//
//  EventMapPreview.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.10.23.
//

import SwiftUI
import MapKit
import Kingfisher

struct EventMapPreview: View {
    let post: Components.Schemas.PostResponseDto
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            HStack(alignment:.top, spacing: 10){
                KFImage(URL(string: post.images[0]))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 8){
                    Text(post.title)
                        .font(.body)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    if let from = post.fromDate{
                        HStack(alignment: .center, spacing: 5) {
                            
                            Text("from: \(separateDateAndTime(from: from).weekday), \(separateDateAndTime(from: from).date)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                            
                            Text("at \(separateDateAndTime(from: from).time)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                        }
                    } else {
                        Text("Anyday")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .fontWeight(.bold)
                    }
                    
                    if let to = post.toDate{
                        HStack(alignment: .center, spacing: 5) {
                            
                            Text("to: \(separateDateAndTime(from: to).weekday), \(separateDateAndTime(from: to).date)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                            
                            Text("at \(separateDateAndTime(from: to).time)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                        }
                    }
                    
                    HStack(alignment: .center, spacing: 5) {
                        if let address = post.location.address{
                            Text("\(address),")
                                .font(.footnote)
                                .foregroundStyle(.gray)
                                .multilineTextAlignment(.leading)
                        }
                        
                        if let city = post.location.city{
                            Text("\(city)")
                                .font(.footnote)
                                .foregroundStyle(.gray)
                                .multilineTextAlignment(.leading)
                        } else if let country = post.location.country {
                            Text("\(country)")
                                .font(.footnote)
                                .foregroundStyle(.gray)
                                .multilineTextAlignment(.leading)
                        }
                    }

                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            Spacer()
            
            HStack(spacing: 30) {
                HStack(spacing: 3) {
                    Image(systemName: "person.2")
                        .foregroundStyle(.gray)
                    if let maxPeople = post.maximumPeople {
                        Text("\(post.participantsCount)/\(maxPeople)")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("\(post.participantsCount)")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.leading)
                    }
                    
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
                        Text("\(post.currency?.symbol ?? "€") \(String(format: "%.2f", post.payment))")
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
    EventMapPreview(post: MockPost)
}
