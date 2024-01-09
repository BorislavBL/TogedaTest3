//
//  GroupCell.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 8.01.24.
//

import SwiftUI

struct GroupCell: View {
    @Environment(\.colorScheme) var colorScheme
    var club: Club = .MOCK_CLUBS[0]
    @EnvironmentObject var userViewModel: UserViewModel
    var size: ImageSize = .xMedium
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 15){
                
                //MARK: - Post Header
                header()
                
                NavigationLink(value: club){
                    Image(club.imagesUrl[0])
                        .resizable()
                        .scaledToFill()
                        .frame(maxHeight: 400)
                        .cornerRadius(10)
                }
                
                //MARK: - Buttons
                HStack(alignment: .center, spacing: 20){
                    Button {
                        
                    } label: {
                        Image(systemName: club.members.contains(where:{userViewModel.user.id == $0.userID}) ? "person.2.circle.fill" : "person.2.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    
                    
                    Button{
                        let url = URL(string: "maps://?saddr=&daddr=\(club.baseLocation.latitude),\(club.baseLocation.longitude)")
                        if UIApplication.shared.canOpenURL(url!) {
                            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                        }
                    } label: {
                        Image(systemName: "mappin.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    
                    
                    Button {
                        
                    } label: {
                        
                        Image(systemName: "paperplane")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    
                    Spacer()
                }
                .foregroundColor(Color("textColor"))
                
                //MARK: - Tags
                GroupCellTags(club: club)
            }
            
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color("postCellColor"))
        .cornerRadius(10)
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    func header() -> some View {
        HStack{
            NavigationLink(value: club){
                if club.members.count > 1 {
                    ZStack(alignment:.top){
                        
                        Image(club.members[1].user.profileImageUrl[0])
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                                    .stroke(strokeColor, lineWidth: 2)
                            )
                            .offset(x:size.dimension/5, y: size.dimension/5)
                        
                        Image(club.members[0].user.profileImageUrl[0])
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                                    .stroke(strokeColor, lineWidth: 2)
                            )
                    }
                    .padding([.trailing, .bottom], size.dimension/5)
                    
                } else{
                    Image(club.members[0].user.profileImageUrl[0])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .background(.gray)
                        .cornerRadius(15)
                }
                
                
                VStack(alignment: .leading, spacing: 3){
                    Text(club.title)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    if club.members.count > 2 {
                        Text("\(club.members[0].user.firstName), \(club.members[1].user.firstName) and more")
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)
                            .font(.footnote)
                    } else if club.members.count > 1 {
                        Text("\(club.members[0].user.firstName), \(club.members[1].user.firstName)")
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)
                            .font(.footnote)
                    } else {
                        Text("\(club.members[0].user.firstName)")
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)
                            .font(.footnote)
                    }
                    
                }
            }
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
            }
            
        }
    }
    
    var strokeColor: Color {
        if colorScheme == .dark {
            return Color(.systemGray6)
        } else {
            return Color("base")
        }
    }
}


#Preview {
    GroupCell()
        .environmentObject(UserViewModel())
}
