//
//  GroupCellTags.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 9.01.24.
//

import SwiftUI
import WrappingHStack

struct ClubCellTags: View {
    var club: Components.Schemas.ClubDto
    
    var body: some View {
        WrappingHStack(alignment: .leading, horizontalSpacing: 5) {
            
            HStack(spacing: 3) {
                Image(systemName: "globe.europe.africa.fill")
                if club.askToJoin {
                    Text("Ask to join")
                        .normalTagTextStyle()
                } else {
                    Text(club.accessibility.rawValue.capitalized)
                        .normalTagTextStyle()
                }
            }
            .normalTagCapsuleStyle()
            
            HStack(spacing: 3) {
                Image(systemName: "location")
//                Text(locationCityAndCountry(club.baseLocation))
                Text(club.location.name)
                    .normalTagTextStyle()
            }
            .normalTagCapsuleStyle()
            
            
            HStack(spacing: 3) {
                Image(systemName: "person.2")
                Text("\(formatBigNumbers(Int(club.membersCount)))")
                    .normalTagTextStyle()
            }
            .normalTagCapsuleStyle()
            
        }
    }
}

#Preview {
    ClubCellTags(club: MockClub)
}
