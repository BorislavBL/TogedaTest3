//
//  ProfileView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    var user: User
    
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
                        ForEach(user.profilePhotos, id: \.self) { image in
                            Image(image)
                                .resizable()
                                .scaledToFill()
                                .clipped()
                            
                        }
                        
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 500)
                    
                    VStack(spacing: 10) {
                        Text(user.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 5){
                            Image(systemName: "suitcase")
                            
                            Text("Graphic Designer")
                                .font(.footnote)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.gray)
                        
                        
                        HStack(spacing: 5){
                            Image(systemName: "mappin.circle")
                            
                            Text(user.location.name)
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                        }
                        .foregroundColor(.gray)
                        
                        
                    }.padding()
                    
                    HStack(alignment: .top, spacing: 30) {
                        UserStats(value: String(user.details.friendIds.count), title: "Friends")
                        Divider()
                        UserStats(value: String(user.details.createdEventIds.count), title: "Events")
                        Divider()
                        UserStats(value: "\(10)%", title: "Rating")
                    }
                    .padding()
                    
                }
                /*               .padding(.top, safeAreaInsets.top + 50)*/ // if you move this part you might break the geomrty reader
                
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
                AboutTab(user: user)
                EventTab(userID: user.id)
                ClubsTab(userID: user.id)
                
            }
            .edgesIgnoringSafeArea(.top)
            .frame(maxWidth: .infinity)
            .background(Color("testColor"))
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
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder
    func navbar() -> some View {
        HStack(alignment: .center, spacing: 10) {
            Spacer()
            // adjust the spacing value as needed
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
        .padding(.horizontal)
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: User.MOCK_USERS[0])
            .environmentObject(UserViewModel())
            .environmentObject(PostsViewModel())
    }
}
