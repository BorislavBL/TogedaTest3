//
//  EventComponent2.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 28.12.23.
//

import SwiftUI
import WrappingHStack

struct EventComponent: View {
    var userID: String
    var post: Post
    let size: CGSize = CGSize(width: (UIScreen.main.bounds.width / 2) - 16, height: ((UIScreen.main.bounds.width / 2) - 16) * 1.5)

    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(post.imageUrl[0])
                .resizable()
                .scaledToFill()
                .frame(size)
                .clipped()
            
            LinearGradient(gradient: Gradient(colors: [.black.opacity(0), .black.opacity(0), .black]), startPoint: .top, endPoint: .bottom)
                .opacity(0.95)
            
            VStack(alignment: .leading){
                
                if let user = post.user, user.id == userID {
                    Text("Hosted")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("lightGray"))
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
                    HStack{
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(post.hasEnded ? .red : Color("lightGray"))
                        Text(post.hasEnded ? "Ended" : "\(separateDateAndTime(from: post.date).date)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(post.hasEnded ? .red : Color("lightGray"))
                    }
                    
                    HStack{
                        Image(systemName: "person.3.fill")
                            .font(.caption)
                            .foregroundColor(Color("lightGray"))
                        if post.maximumPeople > 0 {
                            Text("\(post.peopleIn.count)/\(post.maximumPeople)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("lightGray"))
                        } else {
                            Text("\(post.peopleIn.count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("lightGray"))
                        }
                    }
                }
                .padding(.bottom, 2)

                if let country = post.location.country, let city = post.location.city {
                    HStack(alignment: .center){
                        Image(systemName: "location")
                            .font(.caption)
                            .foregroundColor(Color("lightGray"))
                        
                        Text("\(city), \(country)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("lightGray"))
                    }
                    
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
    EventComponent(userID: User.MOCK_USERS[0].id, post: Post.MOCK_POSTS[0])
}
