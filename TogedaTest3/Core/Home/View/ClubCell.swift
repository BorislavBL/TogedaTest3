//
//  GroupCell.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 8.01.24.
//

import SwiftUI
import Kingfisher

struct ClubCell: View {
    @Environment(\.colorScheme) var colorScheme
    var club: Components.Schemas.ClubDto
    @EnvironmentObject var vm: ClubsViewModel
    var size: ImageSize = .xMedium
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State var clubMembers: [Components.Schemas.ExtendedMiniUserForClub] = []
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 15){
                
                //MARK: - Post Header
                header()
                
                NavigationLink(value: SelectionPath.club(club)){
                    KFImage(URL(string: club.images[0]))
                        .resizable()
                        .scaledToFill()
                        .frame(maxHeight: 400)
                        .cornerRadius(10)
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
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color("postCellColor"))
        .cornerRadius(10)
        .padding(.horizontal, 8)
        .onAppear(){
            Task{
                do{
                    if let response = try await APIClient.shared.getClubMembers(clubId: club.id, page: 0, size: 3) {
                        
                        clubMembers = response.data
                    }
                    
                } catch {
                    print("Fetch Memebres error:", error.localizedDescription)
                }
            }
        }
    }
    
    @ViewBuilder
    func header() -> some View {
        HStack{
            NavigationLink(value: SelectionPath.club(club)){
                if clubMembers.count > 1 {
                    ZStack(alignment:.top){
                        
                        KFImage(URL(string:clubMembers[1].user.profilePhotos[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                                    .stroke(strokeColor, lineWidth: 2)
                            )
                            .offset(x:size.dimension/5, y: size.dimension/5)
                        
                        KFImage(URL(string:clubMembers[0].user.profilePhotos[0]))
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
                    
                } else if clubMembers.count == 1{
                    KFImage(URL(string:clubMembers[0].user.profilePhotos[0]))
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
                    
                    if clubMembers.count > 2 {
                        Text("\(clubMembers[0].user.firstName), \(clubMembers[1].user.firstName) and more")
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)
                            .font(.footnote)
                    } else if clubMembers.count > 1 {
                        Text("\(clubMembers[0].user.firstName), \(clubMembers[1].user.firstName)")
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)
                            .font(.footnote)
                    } else if clubMembers.count == 1 {
                        Text("\(clubMembers[0].user.firstName)")
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)
                            .font(.footnote)
                    } else {
                        
                    }
                    
                }
            }
            Spacer()
            
            Button {
                vm.clickedClub = club
                vm.showOption = true
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
    ClubCell(club: MockClub)
        .environmentObject(ClubsViewModel())
        .environmentObject(UserViewModel())
}
