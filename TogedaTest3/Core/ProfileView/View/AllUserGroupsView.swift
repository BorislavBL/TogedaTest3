//
//  AllUserGroupsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 2.01.24.
//

import SwiftUI

struct AllUserGroupsView: View {
    var userID: String
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView{
            LazyVGrid(columns: columns){
                ForEach(0..<6, id:\.self ){ index in
                    GroupComponent(userID: userID, club: Club.MOCK_CLUBS[0])
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical)
        }
        .refreshable {
            
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Clubs")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {dismiss()}) {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .background(.bar)
    }

}

#Preview {
    AllUserGroupsView(userID: "")
}
