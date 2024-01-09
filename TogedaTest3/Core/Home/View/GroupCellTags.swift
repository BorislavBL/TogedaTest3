//
//  GroupCellTags.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 9.01.24.
//

import SwiftUI
import WrappingHStack

struct GroupCellTags: View {
    var club: Club
    
    var body: some View {
        WrappingHStack(alignment: .leading, horizontalSpacing: 5) {
            
            HStack(spacing: 3) {
                Image(systemName: "globe.europe.africa.fill")
                if club.askToJoin {
                    Text("Ask to join")
                        .normalTagTextStyle()
                } else {
                    Text(club.visability.value)
                        .normalTagTextStyle()
                }
            }
            .normalTagCapsuleStyle()
                
                HStack(spacing: 3) {
                    Image(systemName: "location")
                    Text(club.baseLocation.name)
                        .normalTagTextStyle()
                }
                .normalTagCapsuleStyle()
            
            
            HStack(spacing: 3) {
                Image(systemName: "person.3")
                Text("\(club.members.count)")
                    .normalTagTextStyle()
            }
            .normalTagCapsuleStyle()
            
            HStack(spacing: 3) {
                Image(systemName: "square.grid.2x2")
                Text(club.category)
                    .normalTagTextStyle()
            }
            .normalTagCapsuleStyle()

        }
    }
}

#Preview {
    GroupCellTags(club: Club.MOCK_CLUBS[0])
}
