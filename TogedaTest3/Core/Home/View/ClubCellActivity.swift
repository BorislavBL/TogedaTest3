//
//  ClubCellActivity.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 9.07.24.
//

import SwiftUI
import Kingfisher

struct ClubCellActivity: View {
    var club: Components.Schemas.ClubDto
    var miniUser: Components.Schemas.MiniUser = MockMiniUser
    var body: some View {
        VStack{
            HStack(alignment: .center) {
                NavigationLink(value: SelectionPath.profile(miniUser)) {
                    HStack(alignment: .center) {
                        KFImage(URL(string: miniUser.profilePhotos[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .background(.gray)
                            .clipShape(Circle())
                            
                        Text("\(miniUser.firstName) \(miniUser.lastName) ")
                            .fontWeight(.semibold)
                            .font(.footnote) +
                        
                        Text("Joined this club")
                            .foregroundColor(.gray)
                            .font(.footnote)
                        
                    }
                    .multilineTextAlignment(.leading)
                    
                }
                
                Spacer()
            }
            
            Divider()
                .padding(.vertical, 8)

            ClubCellSkeleton(club: club)
          

        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color("postCellColor"))
        .cornerRadius(10)
        .padding(.horizontal, 8)
    }
}

#Preview {
    ClubCellActivity(club: MockClub)
        .environmentObject(ClubsViewModel())
        .environmentObject(UserViewModel())
}
