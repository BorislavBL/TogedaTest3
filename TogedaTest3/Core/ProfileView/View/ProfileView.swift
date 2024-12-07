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
    @EnvironmentObject var mainVM: ContentViewModel
    
    @State var showSheet: Bool = false
    @State var showCreateEvent: Bool = false
    @State var showCreateClub: Bool = false
    @StateObject var viewModel = ProfileViewModel()
    
    @State var Init: Bool = true
    @State var InitEvent: Bool = true
    @State var InitClub: Bool = true

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
                            HStack(spacing: 5){
                                Text("\(user.firstName) \(user.lastName)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                
                                if user.userRole == .PARTNER {
                                    PartnerSeal()
                                } else if user.userRole == .AMBASSADOR {
                                    AmbassadorSeal()
                                }
                                
                            }
                            
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
                                UserStats(value: formatBigNumbers(Int(user.friendsCount)), title: "Friends")
                                    .frame(width: 105)
                            }
                            Divider()
                                .frame(height: 50)
                            
                            NavigationLink(value: SelectionPath.allUserEvents(userID: user.id)){
                                UserStats(value: formatBigNumbers(Int(user.participatedPostsCount)), title: "Events")
                                    .frame(width: 105)
                            }
                            Divider()
                                .frame(height: 50)
                            
                            NavigationLink(value: SelectionPath.userReviewView(user: user)){
                                VStack{
                                    UserStats(value: "\(formatBigNumbers(Int(viewModel.likesCount)))", title: "Likes")
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
                    
                    AboutTab(user: user, badges: viewModel.badges, showInstagram: true)
                    if viewModel.badgeTasks.count > 0 {
                        UserTaskView(badgeTask: viewModel.badgeTasks[0], referralCode: user.details.referralCode, badgesLeft: viewModel.badgeSupply)
                    }
                    
                    EventTab(userID: user.id, posts: $viewModel.posts, createEvent: $showCreateEvent, count: $viewModel.postsCount)
                    
                    ClubsTab(userID: user.id, count: viewModel.clubsCount, createClub: $showCreateClub, clubs: $viewModel.clubs)
                    
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
                        await viewModel.fetchAllData(userId: user.id, _posts: $userVm.posts, _clubs: $userVm.clubs)
                        
                    }
                })
                .onAppear(){
                    if Init {
                        viewModel.posts = []
                        viewModel.clubs = []
                        Task{
                            await viewModel.fetchAllData(userId: user.id, _posts: $userVm.posts, _clubs: $userVm.clubs)
                        }
                        
                        Init = false
                    }
                    else {
                        Task{
                            if let response = try await APIClient.shared.getFriendList(userId: user.id, page: 0, size: 1){
                                userVm.currentUser?.friendsCount = Double(response.listCount)
                            }
                        }
                    }
                }
                .edgesIgnoringSafeArea(.top)
                .frame(maxWidth: .infinity)
                .background(Color("testColor"))
                .onChange(of: userVm.posts) { oldValue, newValue in
                    let countDifference = newValue.count - oldValue.count
                    if !viewModel.postsAreUpdating {
                        viewModel.posts = newValue
                        viewModel.postsCount = max(viewModel.postsCount + Int64(countDifference), 0)
                    } else {
                        viewModel.postsAreUpdating = false
                    }
                }
                .onChange(of: userVm.clubs) { oldValue, newValue in
                    let countDifference = newValue.count - oldValue.count
                    if !viewModel.clubsAreUpdating {
                        viewModel.clubs = newValue
                        viewModel.clubsCount = max(viewModel.clubsCount + Int64(countDifference), 0)
                    } else {
                        viewModel.clubsAreUpdating = false
                    }
                }
                
                navbar()
                
            } else {
                UserProfileSkeletonView()
                HStack(alignment: .center, spacing: 10) {
                    Spacer()
                    Button{
                        mainVM.logout()
                    }label:{
                        Text("Log out")
                            .font(.footnote)
                            .bold()
                            .frame(height: 35)
                            .padding(.horizontal)
                            .background(.bar)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
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
            
            Menu {
                NavigationLink(value: SelectionPath.userSettings(isSupportNeeded: false)) {
                    HStack{
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                }
                
                Button {
                    userVm.showInstaOverlay = true
                } label: {
                    HStack{
                        Image("instagram")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        
                        Text("Insta Story")
                    }
                }
                
                if let user = userVm.currentUser {
                    ShareLink(item: URL(string: createURLLink(postID: nil, clubID: nil, userID: user.id))!) {
                        HStack{
                            Image(systemName: "paperplane")
                            
                            Text("Share via")
                        }
                    }
                }
            } label: {
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
