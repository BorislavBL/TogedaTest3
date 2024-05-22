//
//  UserProfileView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.10.23.
//

import SwiftUI
import WrappingHStack
import Kingfisher

struct UserProfileView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @Environment(\.dismiss) private var dismiss
    var miniUser: Components.Schemas.MiniUser
    @State var user: Components.Schemas.User?
    @EnvironmentObject var userVm: UserViewModel
    
    @State var showSheet: Bool = false
    @State var showCreateEvent: Bool = false
    @State var showCreateClub: Bool = false
    
    var body: some View {
        ZStack(alignment: .top){
            ScrollView(showsIndicators: false){
                VStack(alignment: .center) {
                    TabView {
                        ForEach(miniUser.profilePhotos, id: \.self) { image in
                            KFImage(URL(string:image))
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width)
                                .clipped()
                            
                        }
                        
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: UIScreen.main.bounds.width * 1.5)
                    
                    VStack(spacing: 10) {
                        Text("\(miniUser.firstName) \(miniUser.lastName)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        WrappingHStack(horizontalSpacing: 5, verticalSpacing: 5){
                            HStack(spacing: 5){
                                Image(systemName: "suitcase")
                                
                                Text(miniUser.occupation)
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.gray)
                            
//                            if let age = calculateAge(from: miniUser.birthDate){
                                HStack(spacing: 5){
                                    Image(systemName: "birthday.cake")
                                    
                                    Text("\(23)y")
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.gray)
//                            }
                        }
                        
                        
                        HStack(spacing: 5){
                            Image(systemName: "mappin.circle")
                            
                            Text(user?.location.name)
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                        }
                        .foregroundColor(.gray)
                        
                        
                    }.padding()
                    
                    HStack(alignment: .top, spacing: 30
                    ) {
                        UserStats(value: String(user?.details?.friendIds?.count ?? 0), title: "Friends")
                        Divider()
                        UserStats(value: String(user?.details?.createdEventIds?.count ?? 0), title: "Events")
                        Divider()
                        UserStats(value: "\(10)%", title: "Rating")
                    }
                    .padding(.bottom)
                    
                    if let user = userVm.currentUser, miniUser.id != user.id {
                        HStack(alignment:.center, spacing: 10) {
                            Button {
                                
                            } label: {
                                Text("Add Friend")
                                    .normalTagTextStyle()
                                    .frame(width: UIScreen.main.bounds.width/2 - 60)
                                    .normalTagRectangleStyle()
                            }
                            Button {
                                
                            } label: {
                                Text("Message")
                                    .normalTagTextStyle()
                                    .frame(width: UIScreen.main.bounds.width/2 - 60)
                                    .normalTagRectangleStyle()
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    
                }
                .padding(.bottom)
                .frame(width: UIScreen.main.bounds.width)
                .background(.bar)
                .cornerRadius(10)
                
                BadgesTab()
                
                AboutTab(user: user)
                
                EventTab(userID: miniUser.id, createEvent: $showCreateEvent)
                ClubsTab(userID: miniUser.id)
                
            }
            .edgesIgnoringSafeArea(.top)
            .frame(maxWidth: .infinity)
            .background(Color("testColor"))
            .navigationBarBackButtonHidden(true)
            
            navbar()
        }
        .sheet(isPresented: $showSheet, content: {
            CreateSheetView(showSheet: $showSheet, showCreateEvent: $showCreateEvent, showCreateClub: $showCreateClub)
        })
        .fullScreenCover(isPresented: $showCreateClub, content: {
            CreateGroupView()
        })
        .fullScreenCover(isPresented: $showCreateEvent, content: {
            CreateEventView()
        })
        .onAppear(){
            if let user = userVm.currentUser, miniUser.id != user.id {
                Task {
                    self.user = try await APIClient.shared.getUserInfo(userId: miniUser.id)
                }
            } else {
                user = userVm.currentUser
            }
        }
    }
    
    @ViewBuilder
    func navbar() -> some View {
        HStack(alignment: .center, spacing: 10) {
            Button(action: {dismiss()}) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                    .navButton3()
            }
            
            Spacer()
            // adjust the spacing value as needed
            if let user = userVm.currentUser, miniUser.id == user.id {
                Button {
                    showSheet = true
                } label: {
                    Image(systemName: "plus.square")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                        .navButton3()
                }
                
                NavigationLink(value: SelectionPath.userSettings) {
                    Image(systemName: "gear")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                        .navButton3()
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    UserProfileView(miniUser: MockMiniUser, user: MockUser)
        .environmentObject(UserViewModel())
}
