//
//  ProfileView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import Kingfisher
import SkeletonUI
import WrappingHStack

struct ProfileView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var userVm: UserViewModel
    
    @State var showSheet: Bool = false
    @State var showCreateEvent: Bool = false
    @State var showCreateClub: Bool = false
    
    var body: some View {
        ZStack(alignment: .top){
            if let user = userVm.currentUser {
                ScrollView(showsIndicators: false){
                    VStack(alignment: .center){
                        TabView {
                            ForEach(user.profilePhotos, id: \.self) { image in
                                KFImage(URL(string: image))
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .frame(height: UIScreen.main.bounds.width * 1.5)
                        
                        VStack(spacing: 10) {
                            Text("\(user.firstName) \(user.lastName)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            WrappingHStack(horizontalSpacing: 5, verticalSpacing: 5){
                                HStack(spacing: 5){
                                    Image(systemName: "suitcase")
                                    
                                    Text(user.occupation)
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.gray)

                                if let age = calculateAge(from: user.birthDate){
                                    HStack(spacing: 5){
                                        Image(systemName: "birthday.cake")
                                        
                                        Text("\(age)y")
                                            .font(.footnote)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.gray)
                                }
                            }
                            
                            HStack(spacing: 5){
                                Image(systemName: "mappin.circle")
                                
                                Text(locationCityAndCountry1(user.location))
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                            }
                            .foregroundColor(.gray)
                            
                            
                        }.padding()
                        
                        HStack(alignment: .top, spacing: 30) {
                            UserStats(value: String((user.details?.friendIds!.count)!), title: "Friends")
                            Divider()
                            UserStats(value: String((user.details?.createdEventIds!.count)!), title: "Events")
                            Divider()
                            UserStats(value: "\(100)%", title: "Rating")
                        }
                        .padding(.bottom)
                        
                    }
                    .padding(.bottom)
                    .frame(width: UIScreen.main.bounds.width)
                    .background(.bar)
                    .cornerRadius(10)

                    BadgesTab()
                    
                    if let user = userVm.currentUser, !user.verifiedPhone {
                        VerifyPhoneProfileTab()
                    }
                    
                    AboutTab(user: user)
                    EventTab(userID: user.id, createEvent: $showCreateEvent)
                    ClubsTab(userID: user.id)
                    
                }
                .edgesIgnoringSafeArea(.top)
                .frame(maxWidth: .infinity)
                .background(Color("testColor"))
                navbar()
                
            } else {
                UserProfileSkeletonView()
            }
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
    
    var foregroundColor: Color {
        if colorScheme == .dark {
            return Color(.white)
        } else {
            return Color(.black)
        }
    }
    
    var backgroundColor: Color {
        if colorScheme == .dark {
            return Color(.systemGray5)
        } else {
            return Color(.systemGray6)
        }
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
            
            NavigationLink(value: SelectionPath.userSettings) {
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
        ProfileView()
            .environmentObject(UserViewModel())
            .environmentObject(PostsViewModel())
            .environmentObject(ContentViewModel())
    }
}
