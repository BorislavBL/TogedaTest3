//
//  AboutTab.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import WrappingHStack

struct AboutTab: View {
    var user: User
    var body: some View {
        VStack (alignment: .leading) {
            if isAboutInfo {
                Text("About Me")
                    .font(.body)
                    .fontWeight(.bold)
                WrappingHStack(alignment: .leading){
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
                            
                            Text("\(height) cm (\(convertCmToFeetAndInches(height) ?? "feet"))")
                                .normalTagTextStyle()
                        }
                        .normalTagCapsuleStyle()
                    }
                    
                    if let workout = user.details.workout {
                        aboutTag(img: Image(systemName: "dumbbell"), text: workout)
                    }
                    if let personalityType = user.details.personalityType {
                        aboutTag(img: Image(systemName: "puzzlepiece.extension"), text: personalityType)
                    }
                    if let instagarm = user.details.instagram {
                        aboutTag(img:Image("instagram"), text: instagarm)
                    }
                    
                }.padding(.bottom, 30)
            }
            
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
            
            if let bio = user.details.bio, !bio.isEmpty {
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
        if user.details.education != nil || user.details.workout != nil || user.details.personalityType != nil || user.details.instagram != nil {
            return true
        } else {
            return false
        }
    }
}

struct AboutTab_Previews: PreviewProvider {
    static var previews: some View {
        AboutTab(user: User.MOCK_USERS[0])
    }
}

