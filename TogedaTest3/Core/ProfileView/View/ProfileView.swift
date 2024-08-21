//
//  ProfileView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import Kingfisher
import WrappingHStack
import Refresher

struct ProfileView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var userVm: UserViewModel
    
    @State var showSheet: Bool = false
    @State var showCreateEvent: Bool = false
    @State var showCreateClub: Bool = false
    @StateObject var viewModel = ProfileViewModel()
    
    @State var InitEvent: Bool = true
    
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
                                
                                //                                Text(locationCityAndCountry(user.location))
                                Text(user.location.name)
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                            }
                            .foregroundColor(.gray)
                            
                            
                        }.padding()
                        
                        HStack(alignment: .top, spacing: 0) {
                            NavigationLink(value: SelectionPath.userFriendsList(user)){
                                UserStats(value: String(Int(user.friendsCount)), title: "Friends")
                                    .frame(width: 105)
                            }
                            Divider()
                                .frame(height: 50)
                            
                            NavigationLink(value: SelectionPath.allUserEvents(userID: user.id)){
                                UserStats(value: String(Int(user.participatedPostsCount)), title: "Events")
                                    .frame(width: 105)
                            }
                            Divider()
                                .frame(height: 50)
                            
                            NavigationLink(value: SelectionPath.userReviewView(user: user)){
                                VStack{
                                    UserStats(value: "\(viewModel.likesCount)", title: "Likes")
                                    Text("\(viewModel.noShows) no shows")
                                        .font(.footnote)
                                        .foregroundStyle(viewModel.noShows == 0 ? .gray :
                                                            (viewModel.noShows >= 5  && viewModel.noShows < 10) ? .yellow : .red)
                                }
                                .frame(width: 105)
                            }
                        }
                        .padding(.bottom, 8)
                        
                        
                    }
                    .padding(.bottom)
                    .frame(width: UIScreen.main.bounds.width)
                    .background(.bar)
                    .cornerRadius(10)
                    
                    //                    BadgesTab()
                    
                    //                    if let user = userVm.currentUser, !user.verifiedPhone {
                    //                        VerifyPhoneProfileTab()
                    //                    }
                    
                    AboutTab(user: user)
//                    UserTaskView(badgeTask: <#T##Components.Schemas.BadgeTask#>, referralCode: user.details.referralCode)
                    if viewModel.posts.count > 0 {
                        EventTab(userID: user.id, posts: $viewModel.posts, createEvent: $showCreateEvent, count: $viewModel.postsCount)
                    }
                    if viewModel.clubs.count > 0 {
                        ClubsTab(userID: user.id, count: viewModel.clubsCount, clubs: $viewModel.clubs)
                    }
                }
                .refreshable(action: {
                    viewModel.posts = []
                    viewModel.clubs = []
                    Task{
                        do {
                            try await userVm.fetchCurrentUser()
                        } catch {
                            print("Error fetching current user: \(error)")
                        }
                        await viewModel.fetchAllData(userId: user.id)
                        
                    }
                })
                .onAppear(){
                    if InitEvent {
                        viewModel.posts = []
                        viewModel.clubs = []
                        Task{
                            await viewModel.fetchAllData(userId: user.id)
                        }
                        
                        InitEvent = false
                    }
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
            CreateClubView(){
                Task{
                    if let user = userVm.currentUser {
                        try await viewModel.getUserClubs(userId: user.id)
                    }
                }
            }
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
