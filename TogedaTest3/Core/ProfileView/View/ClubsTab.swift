//
//  ClubsTab.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct ClubsTab: View {
    var userID: String
    var count: Int64
    
    @Binding var clubs: [Components.Schemas.ClubDto]
    
    var body: some View {
        VStack (alignment: .leading, spacing: 20) {
            HStack{
                Text("Clubs")
                    .font(.body)
                    .fontWeight(.bold)
                
                Text("\(formatBigNumbers(Int(count)))")
                    .foregroundStyle(.gray)
                
                
                Spacer()
                
                
                NavigationLink(value: SelectionPath.allUserGroups(userID: userID)){
                    Text("View All")
                        .fontWeight(.semibold)
                    
                }
                
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack{
                    ForEach(clubs, id: \.id){ club in
                        NavigationLink(value: SelectionPath.club(club)){
                            GroupComponent(userID: userID, club: club)
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
        ClubsTab(userID: "", count: 0, clubs: .constant([MockClub]))
    }
}

