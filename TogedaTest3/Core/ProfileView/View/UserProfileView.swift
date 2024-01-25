//
//  UserProfileView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.10.23.
//

import SwiftUI

struct UserProfileView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @Environment(\.dismiss) private var dismiss
    var miniUser: MiniUser
    var user: User? {
        User.findUser(byId: miniUser.id)
    }
    let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
    @StateObject var viewModel = ProfileViewModel()
    
    @State var minYValue: CGFloat = 0
    @State private var showImageSet: Bool = true
    
    @State var showSheet: Bool = false
    @State var showCreateEvent: Bool = false
    @State var showCreateClub: Bool = false
    
    var body: some View {
        ZStack(alignment: .top){
            ScrollView(showsIndicators: false){
                
                VStack(alignment: .center) {
                    TabView {
                        ForEach(miniUser.profileImageUrl, id: \.self) { image in
                            Image(image)
                                .resizable()
                                .scaledToFill()
                                .clipped()
                            
                        }
                        
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 500)
                    
                    VStack(spacing: 10) {
                        Text(miniUser.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 5){
                            Image(systemName: "suitcase")
                            
                            Text("Graphic Designer")
                                .font(.footnote)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.gray)
                        
                        if let location = user?.baseLocation.name {
                            HStack(spacing: 5){
                                Image(systemName: "mappin.circle")
                                
                                Text(location)
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                            }
                            .foregroundColor(.gray)
                            
                        }
                    }.padding()
                    
                    HStack(alignment: .top, spacing: 30) {
                        UserStats(value: String(user?.friendIDs.count ?? 0), title: "Friends")
                        Divider()
                        UserStats(value: String(user?.createdEventIDs.count ?? 0), title: "Events")
                        Divider()
                        UserStats(value: "\(10)%", title: "Rating")
                    }
                    .padding()
                    
                    if miniUser.id != userId{
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
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .frame(width: 0, height: 0)
                            .onChange(of: geo.frame(in: .global).minY) { oldMinY,  newMinY in
                                minYValue = newMinY
                            }
                    }
                )
                
                BadgesTab()
                if let user = user {
                    AboutTab(user: user)
                }
                EventTab(userID: miniUser.id)
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
            if miniUser.id == userId {
                Button {
                    showSheet = true
                } label: {
                    Image(systemName: "plus.square")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                        .navButton3()
                }
                
                NavigationLink(destination: UserSettingsView()) {
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
    UserProfileView(miniUser: MiniUser.MOCK_MINIUSERS[0])
}
