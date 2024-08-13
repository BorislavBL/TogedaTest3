//
//  ActivityPostCell.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 9.07.24.
//

import SwiftUI
import Kingfisher

struct ActivityPostCell: View {
    var post: Components.Schemas.PostResponseDto
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
                        

                        
                        if activity.activityType == .JOINED_EVENT {
                            Text("\(activity.user.firstName) \(activity.user.lastName) ")
                                .fontWeight(.semibold)
                                .font(.footnote) +
                            Text("Joined this event.")
                                .foregroundColor(.gray)
                                .font(.footnote)
                        } else if activity.activityType == .CREATED_EVENT {
                            Text("\(activity.user.firstName) \(activity.user.lastName) ")
                                .fontWeight(.semibold)
                                .font(.footnote) +
                            
                            Text("Created this event.")
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

            PostCellSkeleton(post: post)
          

        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color("postCellColor"))
        .cornerRadius(10)
        .padding(.horizontal, 8)
    }
}

#Preview {
    ActivityPostCell(post: MockPost, activity: mockActivityDto)
        .environmentObject(PostsViewModel())
        .environmentObject(UserViewModel())
}

