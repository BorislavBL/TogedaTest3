//
//  GroupCell.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 8.01.24.
//

import SwiftUI
import Kingfisher

struct ClubCell: View {
    var club: Components.Schemas.ClubDto

    var body: some View {
        ClubCellSkeleton(club: club)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color("postCellColor"))
            .cornerRadius(10)
            .padding(.horizontal, 8)

    }

    

}


struct ClubCellSkeleton: View {
    var club: Components.Schemas.ClubDto
    
    @EnvironmentObject var vm: ClubsViewModel
    var size: ImageSize = .xMedium
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 15){
                
                //MARK: - Post Header

                ZStack(alignment: .top){
                    VStack(alignment: .center, spacing: 15){
                        headerSpacer()
                            .opacity(0)
                        
//                        NavigationLink(value: SelectionPath.club(club)){
                            KFImage(URL(string: club.images[0]))
                                .resizable()
                                .scaledToFill()
                                .frame(height: 400)
                                .cornerRadius(10)
                                .overlay(
                                    NavigationLink(value: SelectionPath.club(club)) {
                                        Rectangle()
                                            .frame(height: 400)
                                            .opacity(0)
                                    }
                                )
//                        }
                    }
                    
                    header()
                }
                
                //MARK: - Buttons
                HStack(alignment: .center, spacing: 20){
                    if let currentUser = userViewModel.currentUser, currentUser.id == club.owner.id {
                        NavigationLink(value: SelectionPath.club(club)){
                           Image(systemName: club.currentUserStatus == .NOT_PARTICIPATING ? "person.2.circle" : "person.2.circle.fill")
                               .resizable()
                               .scaledToFit()
                               .frame(width: 25, height: 25)
                       }
                    } else {
                        Button {
                            vm.clickedClub = club
                            vm.showJoinClubSheet = true
                        } label: {
                            Image(systemName: club.currentUserStatus == .NOT_PARTICIPATING ? "person.2.circle" : "person.2.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                        }
                    }
                    
                    
                    Button{
                        let url = URL(string: "maps://?saddr=&daddr=\(club.location.latitude),\(club.location.longitude)")
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
                        vm.clickedClub = club
                        vm.showShareClubSheet = true
                        print("Clicked")
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
                ClubCellTags(club: club)
            }
            
        }
    }
    
    @ViewBuilder
    func header() -> some View {
        HStack{
            HStack{
                if club.previewMembers.count > 1 {
                    ZStack(alignment:.top){
                        
                        KFImage(URL(string:club.previewMembers[1].profilePhotos[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                                    .stroke(strokeColor, lineWidth: 2)
                            )
                            .offset(x:size.dimension/5, y: size.dimension/5)
                        
                        KFImage(URL(string:club.previewMembers[0].profilePhotos[0]))
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
                    
                } else if club.previewMembers.count == 1{
                    KFImage(URL(string:club.previewMembers[0].profilePhotos[0]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .background(.gray)
                        .cornerRadius(15)
                } else {
                    Rectangle()
                        .foregroundStyle(.gray)
                        .frame(width: 50, height: 50)
                        .cornerRadius(15)
                }
                
                
                VStack(alignment: .leading, spacing: 3){
                    Text(club.title)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    if club.previewMembers.count > 2 {
                        Text("\(club.previewMembers[0].firstName), \(club.previewMembers[1].firstName) and more")
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)
                            .font(.footnote)
                    } else if club.previewMembers.count > 1 {
                        Text("\(club.previewMembers[0].firstName), \(club.previewMembers[1].firstName)")
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)
                            .font(.footnote)
                    } else if club.previewMembers.count == 1 {
                        Text("\(club.previewMembers[0].firstName)")
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)
                            .font(.footnote)
                    } else {
                        
                    }
                    
                }
            }
            .overlay {
                NavigationLink(value: SelectionPath.club(club)){
                    headerSpacer()
                        .opacity(0)
                }
            }
            
            Spacer()
            
            Menu{
                ShareLink(item: URL(string: createURLLink(postID: nil, clubID: club.id, userID: nil))!) {
                    Text("Share via")
                }
                
                if isOwner {

                } else {
                    Button("Report") {
                        vm.clickedClub = club
                        vm.showReport = true
                    }
                }
                
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .padding(8)
            }
        }
    }
    
    // This view is used to create the perfect height of the header.
    //The reason thats needed its because the clipped image overlaps the menu button and it doesnt trigger. That minght be fixed in future versions so check regularly.
    func headerSpacer() -> some View {
            HStack(alignment: .center) {
                if club.previewMembers.count > 1 {
                    ZStack(alignment:.top){
                        Rectangle()
                            .foregroundStyle(.gray)
                            .frame(width: size.dimension, height: size.dimension)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                                    .stroke(strokeColor, lineWidth: 2)
                            )
                            .offset(x:size.dimension/5, y: size.dimension/5)
                        
                        Rectangle()
                            .foregroundStyle(.gray)
                            .frame(width: size.dimension, height: size.dimension)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                                    .stroke(strokeColor, lineWidth: 2)
                            )
                    }
                    .padding([.trailing, .bottom], size.dimension/5)
                    
                } else {
                    Rectangle()
                        .foregroundStyle(.gray)
                        .frame(width: 50, height: 50)
                        .cornerRadius(15)
                }
                
                VStack(alignment: .leading, spacing: 3){
                    Text(club.title)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    Text("\(club.owner.firstName) \(club.owner.lastName)")
                        .foregroundColor(.gray)
                        .fontWeight(.semibold)
                        .font(.footnote)
                }
                
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .padding(8)
            }
            
    }
    
    var isOwner: Bool {
        if let currentUser = userViewModel.currentUser, currentUser.id == club.owner.id{
            return true
        } else {
            return false
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
    ClubCell(club: MockClub)
        .environmentObject(ClubsViewModel())
        .environmentObject(UserViewModel())
}
