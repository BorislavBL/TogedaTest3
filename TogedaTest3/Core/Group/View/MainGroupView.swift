//
//  MainGroupView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 2.01.24.
//

import SwiftUI

struct MainGroupView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @ObservedObject var groupVM: GroupViewModel
    @Binding var showShareSheet: Bool
    var userID: String
    
    var body: some View {
        VStack(alignment: .center) {
            TabView {
                ForEach(groupVM.club.imagesUrl, id: \.self) { image in
                    Image(image)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 500)
            
            VStack(spacing: 10) {
                Text(groupVM.club.title)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 5){
                    Image(systemName: "mappin.circle")
                    
                    Text(locationAddress(groupVM.club.baseLocation))
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.gray)
                
                    HStack(spacing: 5){
                        Image(systemName: "eye")
                        
                        Text(groupVM.club.visability)
                            .font(.footnote)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.gray)

                HStack(alignment:.center, spacing: 10) {
                    if groupVM.club.members.contains(where: { ClubMember in
                        ClubMember.userID == userID
                    }) {
                        Button {
                            
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
    MainGroupView(groupVM: GroupViewModel(), showShareSheet: .constant(false), userID: MiniUser.MOCK_MINIUSERS[0].id)
}
