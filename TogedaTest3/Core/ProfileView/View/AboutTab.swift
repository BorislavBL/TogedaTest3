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
    
    var body: some View{
        VStack (alignment: .leading) {
            Text("About Me")
                .font(.body)
                .fontWeight(.bold)
            WrappingHStack(alignment: .leading){
                ForEach(user.abouts, id: \.self){about in
                    Text(about)
                        .normalTagTextStyle()
                        .normalTagCapsuleStyle()
                }
            }.padding(.bottom, 30)
            Text("Interests")
                .font(.body)
                .fontWeight(.bold)
            WrappingHStack(alignment: .leading){
                ForEach(user.interests, id: \.self){interest in
                    Text(interest)
                        .normalTagTextStyle()
                        .normalTagCapsuleStyle()
                }
            }.padding(.bottom, 30)
            
            if let description = user.description {
                
                Text("Description")
                    .font(.body)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                
                ExpandableText(description, lineLimit: 4)
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
}

struct AboutTab_Previews: PreviewProvider {
    static var previews: some View {
        AboutTab(user: User.MOCK_USERS[0])
    }
}

