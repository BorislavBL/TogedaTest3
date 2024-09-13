//
//  AboutTab.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import WrappingHStack

struct AboutTab: View {
    var user: Components.Schemas.UserInfoDto?
    var badges: [Components.Schemas.Badge]?
    var showInstagram: Bool
    var body: some View {
        VStack (alignment: .leading) {
            if isAboutInfo {
                Text("About Me")
                    .font(.body)
                    .fontWeight(.bold)
                
                WrappingHStack(alignment: .leading){
                    
                    if let badges = badges, badges.count > 0 {
                        ForEach(badges, id: \.id) { badge in
                            HStack{
                                Text("\(badge.image ?? "⭐️") \(badge.title)")
                                    .normalTagTextStyle()
                            }
                            .normalTagCapsuleStyle()
                        }
                    }
                    
                    if let user = user {
                        if let education = user.details.education {
                            aboutTag(img: Image(systemName: "graduationcap"), text: education)
                        }
                        if let height = user.details.height {
                            HStack{
                                Image(systemName: "ruler")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .rotationEffect(.degrees(115))
                                
                                Text("\(height) cm (\(convertCmToFeetAndInches(String(height)) ?? "feet"))")
                                    .normalTagTextStyle()
                            }
                            .normalTagCapsuleStyle()
                        }
                        
                        if user.visibleGender {
                            aboutTag(img: Image(systemName: "accessibility"), text: user.gender.rawValue.capitalized)
                        }
                        
                        if let workout = user.details.workout {
                            aboutTag(img: Image(systemName: "dumbbell"), text: workout)
                        }
                        if let personalityType = user.details.personalityType {
                            aboutTag(img: Image(systemName: "puzzlepiece.extension"), text: personalityType)
                        }
                        if let instagram = user.details.instagram, !instagram.isEmpty, showInstagram {
                            aboutTag(img:Image("instagram"), text: instagram)
                        }
                    }
                    
                }.padding(.bottom, 30)
            }
            

            
//            if user.interests.count <= 11 {
            if let user = user {
                
                Text("Interests")
                    .font(.body)
                    .fontWeight(.bold)
                
                WrappingHStack(alignment: .leading){
                    ForEach(user.interests, id: \.self){interest in
                        Text("\(interest.icon) \(interest.name)")
                            .normalTagTextStyle()
                            .normalTagCapsuleStyle()
                    }
                }.padding(.bottom, 30)
            }
//            } else {
//                InterestsTranformativeRow(interests: user.interests)
//                .padding(.bottom, 30)
//            }
            
            
            if let user = user, let bio = user.details.bio, !bio.isEmpty {
                Text("Bio")
                    .font(.body)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                
                ExpandableText(bio, lineLimit: 4)
                    .lineSpacing(8.0)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .padding(.bottom, 8)
            }
            
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding()
        .background(.bar)
        .cornerRadius(10)
    }
    
    @ViewBuilder
    func aboutTag(img: Image, text: String) -> some View {
        HStack{
            img
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            Text(text)
                .normalTagTextStyle()
        }
        .normalTagCapsuleStyle()
    }
    
    var isAboutInfo: Bool {
        if let user = user, user.details.education != nil || user.details.workout != nil || user.details.personalityType != nil || user.details.instagram != nil {
            return true
        } else {
            return false
        }
    }
    
    
}

struct AboutTab_Previews: PreviewProvider {
    static var previews: some View {
        AboutTab(user: MockUser, showInstagram: true)
    }
}

