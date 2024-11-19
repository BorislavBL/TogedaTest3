//
//  GroupComponent.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 2.01.24.
//

import SwiftUI
import WrappingHStack
import Kingfisher

struct GroupComponent: View {
    var userID: String
    var club: Components.Schemas.ClubDto
    let size: CGSize = CGSize(width: (UIScreen.main.bounds.width / 2) - 16, height: ((UIScreen.main.bounds.width / 2) - 16) * 1.5)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            KFImage(URL(string: club.images[0]))
                .resizable()
                .scaledToFill()
                .frame(size)
                .clipped()
            
            LinearGradient(gradient: Gradient(colors: [.black.opacity(0), .black.opacity(0), .black]), startPoint: .top, endPoint: .bottom)
                .opacity(0.95)
            
            VStack(alignment: .leading){
                if club.currentUserRole == .ADMIN {
                    Text("Admin")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("light-gray"))
                        .padding(.bottom, 2)
                }
                
                Text(club.title)
                    .font(.footnote)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .padding(.bottom, 5)
                
                WrappingHStack(alignment: .leading, verticalSpacing: 5){
                    
                    HStack{
                        Image(systemName: "eye")
                            .font(.caption)
                            .foregroundColor(Color("light-gray"))
                        if club.askToJoin {
                            Text("Ask to join")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("light-gray"))
                        } else {
                            Text(club.accessibility.rawValue.capitalized)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("light-gray"))
                        }
                    }
                    
                    HStack{
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                            .foregroundColor(Color("light-gray"))
                        
                        Text("\(formatBigNumbers(Int(club.membersCount)))")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("light-gray"))
                    }
                    
                }
                .padding(.bottom, 2)

                
                HStack(alignment: .center){
                    
                    Image(systemName: "location")
                        .font(.caption)
                        .foregroundColor(Color("light-gray"))
                    
                    Text(club.location.name)
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
    GroupComponent(userID: "", club: MockClub)
}
