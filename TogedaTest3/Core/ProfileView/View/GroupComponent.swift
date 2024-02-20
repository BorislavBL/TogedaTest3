//
//  GroupComponent.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 2.01.24.
//

import SwiftUI
import WrappingHStack

struct GroupComponent: View {
    var userID: String
    var club: Club
    let size: CGSize = CGSize(width: (UIScreen.main.bounds.width / 2) - 16, height: ((UIScreen.main.bounds.width / 2) - 16) * 1.5)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(club.imagesUrl[0])
                .resizable()
                .scaledToFill()
                .frame(size)
                .clipped()
            
            LinearGradient(gradient: Gradient(colors: [.black.opacity(0), .black.opacity(0), .black]), startPoint: .top, endPoint: .bottom)
                .opacity(0.95)
            
            VStack(alignment: .leading){
                if club.members.contains(where: { ClubMember in
                    if ClubMember.status == "Admin" && ClubMember.userID == userID {
                        return true
                    } else {
                        return false
                    }
                }) {
                    Text("Admin")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("lightGray"))
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
                            .foregroundColor(Color("lightGray"))
                        if club.askToJoin {
                            Text("Ask to join")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("lightGray"))
                        } else {
                            Text(club.visability)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("lightGray"))
                        }
                    }
                    
                    HStack{
                        Image(systemName: "person.3.fill")
                            .font(.caption)
                            .foregroundColor(Color("lightGray"))
                        
                        Text("\(club.members.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("lightGray"))
                    }
                    
                }
                .padding(.bottom, 2)

                
                HStack(alignment: .center){
                    
                    Image(systemName: "location")
                        .font(.caption)
                        .foregroundColor(Color("lightGray"))
                    
                    Text(locationCityAndCountry(club.baseLocation))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("lightGray"))
                    
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
    GroupComponent(userID: User.MOCK_USERS[0].id, club: Club.MOCK_CLUBS[0])
}
