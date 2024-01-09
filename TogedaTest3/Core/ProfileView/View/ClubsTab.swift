//
//  ClubsTab.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct ClubsTab: View {
    var userID: String
    @State var clubs = Club.MOCK_CLUBS
    var body: some View {
        VStack (alignment: .leading, spacing: 20) {
            HStack{
                Text("Clubs")
                    .font(.body)
                    .fontWeight(.bold)
                
                    Text("\(30)")
                        .foregroundStyle(.gray)
                
                
                Spacer()
                
                NavigationLink(destination: AllUserGroupsView(userID: userID)){
                    Text("View All")
                        .fontWeight(.semibold)
                    
                }
                
            }
            .padding(.horizontal)

            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack{
                    ForEach(clubs.indices, id: \.self){ index in
                        NavigationLink( destination: GroupView(clubID: clubs[index].id)){
                            GroupComponent(userID: userID, club: clubs[index])
                        }
                    }
                }
                .padding(.horizontal)
            }

        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(.vertical)
        .background(.bar)
        .cornerRadius(10)
    }
}


struct ClubsTab_Previews: PreviewProvider {
    static var previews: some View {
        ClubsTab(userID: "")
    }
}

