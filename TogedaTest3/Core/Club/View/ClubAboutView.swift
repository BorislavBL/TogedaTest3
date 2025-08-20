//
//  GroupAboutView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.01.24.
//

import SwiftUI
import WrappingHStack

struct ClubAboutView: View {
    var club: Components.Schemas.ClubDto
    
    var body: some View{
        VStack (alignment: .leading) {
            if let description = club.description {
                Text("Description")
                    .font(.body)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                
                ExpandableText(description)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(4)
                    .moreButtonText("read more")
                    .moreButtonFont(.system(.headline, design: .rounded).bold())
                    .trimMultipleNewlinesWhenTruncated(false)
                    .enableCollapse(true)
                    .hasAnimation(false)
                    .padding(.bottom, 30)
            }
            
            Text("Interests")
                .font(.body)
                .fontWeight(.bold)
                .padding(.bottom, 5)
            
                
            InterestsWrapper(interests: club.interests)
                .padding(.bottom, 8)
            
            
            
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding()
        .background(.bar)
        .cornerRadius(10)
    }
}

#Preview {
    ClubAboutView(club: MockClub)
}
