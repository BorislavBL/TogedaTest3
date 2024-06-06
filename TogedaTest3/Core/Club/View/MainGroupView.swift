//
//  MainGroupView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 2.01.24.
//

import SwiftUI
import Kingfisher

struct MainGroupView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @Binding var showShareSheet: Bool
    @Binding var club: Components.Schemas.ClubDto
    @ObservedObject var vm: GroupViewModel
    @Binding var showLeaveSheet: Bool
    var currentUser: Components.Schemas.UserInfoDto?
    
    var body: some View {
        VStack(alignment: .center) {
            TabView {
                ForEach(club.images, id: \.self) { image in
                    KFImage(URL(string: image))
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width)
                        .clipped()
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: UIScreen.main.bounds.width * 1.5)
            
            VStack(spacing: 10) {
                Text(club.title)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 5){
                    Image(systemName: "mappin.circle")
                    
                    Text(locationAddress1(club.location))
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.gray)
                
                    HStack(spacing: 5){
                        Image(systemName: "eye")
                        
                        Text("\(club.accessibility.rawValue.capitalized)")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        if club.askToJoin {
                            Image(systemName: "lock.circle")
                            
                            Text("Ask to join")
                                .font(.footnote)
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundColor(.gray)

                HStack(alignment:.center, spacing: 10) {
                    
                    if club.currentUserStatus == .IN_QUEUE{
                        Button {

                        } label: {
                            Text("Waiting")
                                .normalTagTextStyle()
                                .frame(width: UIScreen.main.bounds.width/2 - 60)
                                .normalTagRectangleStyle()
                        }
                        Button {
                            showShareSheet = true
                        } label: {
                            Text("Share")
                                .normalTagTextStyle()
                                .frame(width: UIScreen.main.bounds.width/2 - 60)
                                .normalTagRectangleStyle()
                        }
                    } else if club.currentUserStatus == .PARTICIPATING {
                        Button {
                            if let user = currentUser, user.id != club.owner.id {
                                showLeaveSheet = true
                            }
                        } label: {
                            Text("Joined")
                                .normalTagTextStyle()
                                .frame(width: UIScreen.main.bounds.width/2 - 60)
                                .normalTagRectangleStyle()
                        }
                        
                        Button {
                            showShareSheet = true
                        } label: {
                            Text("Invite")
                                .normalTagTextStyle()
                                .frame(width: UIScreen.main.bounds.width/2 - 60)
                                .normalTagRectangleStyle()
                        }
                    } else {
                        Button {
                            Task{
                                do{
                                    if try await APIClient.shared.joinClub(clubId: club.id) != nil {
                                        if let response = try await APIClient.shared.getClub(clubID: club.id) {
                                            print("Get Club")
                                            club = response
                                            
                                            vm.clubMembers = []
                                            vm.membersPage = 0
                                            
                                            try await vm.fetchClubMembers(clubId: club.id)
                                        }
                                    }
                                } catch{
                                    print(error)
                                }
                            }
                        } label: {
                            Text("Join")
                                .normalTagTextStyle()
                                .frame(width: UIScreen.main.bounds.width/2 - 60)
                                .normalTagRectangleStyle()
                        }
                        Button {
                            showShareSheet = true
                        } label: {
                            Text("Share")
                                .normalTagTextStyle()
                                .frame(width: UIScreen.main.bounds.width/2 - 60)
                                .normalTagRectangleStyle()
                        }
                    }
                }
                .padding()
            }
            .padding()
        }
        .background(.bar)
        .cornerRadius(10)
        .edgesIgnoringSafeArea(.top)
    }
    

}

#Preview {
    MainGroupView(showShareSheet: .constant(false), club: .constant(MockClub), vm: GroupViewModel(), showLeaveSheet: .constant(false))
}
