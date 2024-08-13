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
    var activity: Components.Schemas.ActivityDto
    var body: some View {
        VStack{
            HStack(alignment: .center) {
                NavigationLink(value: SelectionPath.profile(activity.user)) {
                    HStack(alignment: .center) {
                        KFImage(URL(string: activity.user.profilePhotos[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .background(.gray)
                            .clipShape(Circle())
                            
                        if activity.activityType == .JOINED_CLUB {
                            Text("\(activity.user.firstName) \(activity.user.lastName) ")
                                .fontWeight(.semibold)
                                .font(.footnote) +
                            Text("Joined this club.")
                                .foregroundColor(.gray)
                                .font(.footnote)
                        } else if activity.activityType == .CREATED_CLUB {
                            Text("\(activity.user.firstName) \(activity.user.lastName) ")
                                .fontWeight(.semibold)
                                .font(.footnote) +
                            
                            Text("Created this club.")
                                .foregroundColor(.gray)
                                .font(.footnote)
                        }
                        
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
    ClubCellActivity(club: MockClub, activity: mockActivityDto)
        .environmentObject(ClubsViewModel())
        .environmentObject(UserViewModel())
}
