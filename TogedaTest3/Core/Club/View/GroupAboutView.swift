//
//  GroupAboutView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.01.24.
//

import SwiftUI
import WrappingHStack

struct GroupAboutView: View {
    var club: Components.Schemas.ClubDto
    
    var body: some View{
        VStack (alignment: .leading) {
            if let description = club.description {
                Text("Description")
                    .font(.body)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                
                ExpandableText(description, lineLimit: 4)
                    .lineSpacing(8.0)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .padding(.bottom, 30)
            }
            
            Text("Interests")
                .font(.body)
                .fontWeight(.bold)
                .padding(.bottom, 5)
            
            WrappingHStack(alignment: .leading){
                ForEach(club.interests, id: \.self){interest in
                    Text("\(interest.icon) \(interest.name)")
                        .normalTagTextStyle()
                        .normalTagCapsuleStyle()
                }
            }.padding(.bottom, 8)
            
            
            
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding()
        .background(.bar)
        .cornerRadius(10)
    }
}

#Preview {
    GroupAboutView(club: MockClub)
}
