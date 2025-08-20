//
//  PostTags.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import WrappingHStack

struct PostTags: View {
    @State private var showMoreTags = false
    
    @EnvironmentObject var viewModel: PostsViewModel
    var post: Components.Schemas.PostResponseDto
    
    var body: some View {
        WrappingHStack(alignment: .leading, horizontalSpacing: 5) {
            HStack(spacing: 3) {
                Image(systemName: "wallet.pass")
                if post.payment <= 0{
                    Text("Free")
                        .normalTagTextStyle()
                } else {
                    Text("\(post.currency?.symbol ?? "€") \(String(format:"%.2f", post.payment))")
                        .normalTagTextStyle()
                }
            }
            .normalTagCapsuleStyle()
            
            HStack(spacing: 3) {
                Image(systemName: "calendar")
                if let from = post.fromDate, let to = post.toDate {
                    if separateDateAndTime(from: from).date == separateDateAndTime(from: to).date {
                        Text("\(separateDateAndTime(from: from).date)")
                            .normalTagTextStyle()
                    } else {
                        Text("\(separateDateAndTime(from: from).date) - \(separateDateAndTime(from: to).date)")
                            .normalTagTextStyle()
                    }
                } else if let from = post.fromDate {
                    Text("\(separateDateAndTime(from: from).date)")
                        .normalTagTextStyle()
                } else {
                    Text("Any Day")
                        .normalTagTextStyle()
                }
            }
            .normalTagCapsuleStyle()
            
            if let from = post.fromDate{
                HStack(spacing: 3) {
                    Image(systemName: "clock")
                    if let to = post.toDate {
                        if separateDateAndTime(from: from).time == separateDateAndTime(from: to).time {
                            Text("\(separateDateAndTime(from: from).time)")
                                .normalTagTextStyle()
                        } else {
                            Text("\(separateDateAndTime(from: from).time) - \(separateDateAndTime(from: to).time)")
                                .normalTagTextStyle()
                        }
                    } else {
                        Text("\(separateDateAndTime(from: from).time)")
                            .normalTagTextStyle()
                    }
                }
                .normalTagCapsuleStyle()
            }
            
            HStack(spacing: 3) {
                Image(systemName: "person.2")
                if let maxPeople = post.maximumPeople {
                    Text("\(formatBigNumbers(Int(post.participantsCount)))/\(formatBigNumbers(Int(maxPeople)))")
                        .normalTagTextStyle()
                } else {
                    Text("\(formatBigNumbers(Int(post.participantsCount)))")
                        .normalTagTextStyle()
                }
            }
            .normalTagCapsuleStyle()
            
            
            HStack(spacing: 3) {
                Image(systemName: "location")
                Text(truncatedText(locationCityAndCountry(post.location), maxLength: 25))
                    .normalTagTextStyle()
            }
            .normalTagCapsuleStyle()
       
            HStack(spacing: 3) {
                Image(systemName: "globe.europe.africa.fill")
                if post.askToJoin {
                    Text("Ask to join")
                        .normalTagTextStyle()
                } else {
                    Text(post.accessibility.rawValue.capitalized)
                        .normalTagTextStyle()
                }
            }
            .normalTagCapsuleStyle()
            
            if post.needsLocationalConfirmation {
                HStack(spacing: 3) {
                    Image(systemName: "location.fill.viewfinder")
                    
                    Text("Confirm Location")
                        .normalTagTextStyle()

                }
                .normalTagCapsuleStyle()
            }

            
        }
    }
}

struct PostTags_Previews: PreviewProvider {
    static var previews: some View {
        PostTags(post: MockPost)
            .environmentObject(PostsViewModel())
    }
}


