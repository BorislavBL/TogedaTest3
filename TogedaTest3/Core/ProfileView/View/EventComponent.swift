//
//  EventComponent2.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 28.12.23.
//

import SwiftUI
import WrappingHStack
import Kingfisher

struct EventComponent: View {
    var userID: String
    var post: Components.Schemas.PostResponseDto
    
    let size: CGSize = CGSize(width: (UIScreen.main.bounds.width / 2) - 16, height: ((UIScreen.main.bounds.width / 2) - 16) * 1.5)

    
    var body: some View {
        ZStack(alignment: .bottom) {
            KFImage(URL(string: post.images[0]))
                .resizable()
                .scaledToFill()
                .frame(size)
                .clipped()
            
            LinearGradient(gradient: Gradient(colors: [.black.opacity(0), .black.opacity(0), .black]), startPoint: .top, endPoint: .bottom)
                .opacity(0.95)
            
            VStack(alignment: .leading){
                
                if post.owner.id == userID {
                    Text("Hosted")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("light-gray"))
                        .padding(.bottom, 2)
                    
                        Text("\(post.owner.firstName) \(post.owner.lastName)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("light-gray"))
                            .padding(.bottom, 2)

                }
                
                
                Text(post.title)
                    .font(.footnote)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .padding(.bottom, 5)
                
                WrappingHStack(alignment: .leading, verticalSpacing: 5){
                    if let fromDate = post.fromDate{
                        HStack{
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(post.hasEnded ? .red : Color("light-gray"))
                            Text(post.hasEnded ? "Ended" : "\(separateDateAndTime(from: fromDate).date)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(post.hasEnded ? .red : Color("light-gray"))
                        }
                    }
                    HStack{
                        Image(systemName: "person.3.fill")
                            .font(.caption)
                            .foregroundColor(Color("light-gray"))
                        
                        if let maxPeople = post.maximumPeople {
                            Text("\(post.participantsCount)/\(maxPeople)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("light-gray"))
                        } else {
                            Text("\(post.participantsCount)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("light-gray"))
                        }
                    }
                }
                .padding(.bottom, 2)

                    HStack(alignment: .center){
                        Image(systemName: "location")
                            .font(.caption)
                            .foregroundColor(Color("light-gray"))
                        
                        Text(locationCityAndCountry1(post.location))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("light-gray"))
                            .multilineTextAlignment(.leading)
                    }
                    
                
            }
            
            .padding(.horizontal, 12)
            .padding(.vertical)
            .frame(maxWidth: size.width, maxHeight: size.height, alignment: .bottomLeading)
 
        }
        .frame(size)
        .cornerRadius(20)
    }
}
#Preview {
    EventComponent(userID: "", post: MockPost)
}
