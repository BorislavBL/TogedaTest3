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
            Text("About Me")
                .font(.body)
                .fontWeight(.bold)
            WrappingHStack(alignment: .leading){
                if let education = user.education {
                    aboutTag(img: Image(systemName: "graduationcap"), text: education)
                }
                if let workout = user.workout {
                    aboutTag(img: Image(systemName: "dumbbell"), text: workout)
                }
                if let personalityType = user.personalityType {
                    aboutTag(img: Image(systemName: "puzzlepiece.extension"), text: personalityType)
                }
                if let instagarm = user.instagarm {
                    aboutTag(img:Image("instagram"), text: instagarm)
                }
                
            }.padding(.bottom, 30)
            
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
            
            if let bio = user.bio {
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
    
}

struct AboutTab_Previews: PreviewProvider {
    static var previews: some View {
        AboutTab(user: User.MOCK_USERS[0])
    }
}

