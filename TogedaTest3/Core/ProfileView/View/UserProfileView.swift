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
    @State var miniUser: Components.Schemas.MiniUser
    @State var user: Components.Schemas.UserInfoDto?
    @EnvironmentObject var userVm: UserViewModel
    @EnvironmentObject var websocket: WebSocketManager
    
    @State var Init: Bool = true
    @State var InitEvent: Bool = true
    
    @State var showSheet: Bool = false
    @State var showCreateEvent: Bool = false
    @State var showCreateClub: Bool = false
    
    @StateObject var viewModel = ProfileViewModel()
    
    @State var showRespondSheet = false
    @State var showRemoveSheet = false
    @State var showCancelSheet = false
    @State var showReportSheet = false
    
    var body: some View {
        ZStack(alignment: .top){
            ScrollView(showsIndicators: false){
                VStack(alignment: .center) {
                    TabView {
                        ForEach(miniUser.profilePhotos, id: \.self) { image in
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
                            
                            if let age = calculateAge(from: miniUser.birthDate){
                                HStack(spacing: 5){
                                    Image(systemName: "birthday.cake")
                                    
                                    Text("\(age)y")
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.gray)
                            }
                        }
                        
                        
                        if let location = user?.location.name {
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
                    
                    HStack(alignment: .top, spacing: 0
                    ) {
                        if let user = self.user {
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
                            
                        } else {
                            UserStats(value: String(Int(0)), title: "Friends")
                                .frame(width: 105)
                            
                            
                            Divider()
                                .frame(height: 50)
                            
                            
                            UserStats(value: "\(0)", title: "Events")
                                .frame(width: 105)
                            
                            Divider()
                                .frame(height: 50)
                            
                            
                            VStack{
                                UserStats(value: "\(100)%", title: "Rating")
                                Text("0 no shows")
                                    .font(.footnote)
                                    .foregroundStyle(.gray)
                            }
                            .frame(width: 105)
                            
                        }
                        
                    }
                    .padding(.bottom, 8)
                    
                    if let currentUser = userVm.currentUser, miniUser.id != currentUser.id {
                        HStack(alignment:.center, spacing: 10) {
                            if user?.currentFriendshipStatus == .FRIENDS{
                                Button {
                                    showRemoveSheet = true
                                } label: {
                                    Text("Friends")
                                        .normalTagTextStyle()
                                        .frame(width: UIScreen.main.bounds.width/2 - 60)
                                        .normalTagRectangleStyle()
                                }
                            } else if user?.currentFriendshipStatus == .NOT_FRIENDS{
                                Button {
                                    Task{
                                        if let user = self.user, try await APIClient.shared.sendFriendRequest(sendToUserId: user.id) != nil {
                                            self.user?.currentFriendshipStatus = .SENT_FRIEND_REQUEST
                                        }
                                    }
                                } label: {
                                    Text("Add Friend")
                                        .normalTagTextStyle()
                                        .frame(width: UIScreen.main.bounds.width/2 - 60)
                                        .normalTagRectangleStyle()
                                }
                            } else if user?.currentFriendshipStatus == .RECEIVED_FRIEND_REQUEST {
                                Button {
                                    showRespondSheet = true
                                } label: {
                                    Text("Respond")
                                        .normalTagTextStyle()
                                        .frame(width: UIScreen.main.bounds.width/2 - 60)
                                        .normalTagRectangleStyle()
                                }
                            } else if user?.currentFriendshipStatus == .SENT_FRIEND_REQUEST {
                                Button {
                                    showCancelSheet = true
                                } label: {
                                    Text("Cancel")
                                        .normalTagTextStyle()
                                        .frame(width: UIScreen.main.bounds.width/2 - 60)
                                        .normalTagRectangleStyle()
                                }
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
                
                //                BadgesTab()
                
                AboutTab(user: user)
                

                if viewModel.posts.count > 0 {
                    EventTab(userID: miniUser.id, posts: $viewModel.posts, createEvent: $showCreateEvent, count: $viewModel.postsCount)
                }
                
                if viewModel.clubs.count > 0 {
                    ClubsTab(userID: miniUser.id, count: viewModel.clubsCount, clubs:  $viewModel.clubs)
                }
                
                
            }
            .refreshable(action: {
                viewModel.posts = []
                viewModel.clubs = []
                Task{
                    await fetchAll()
                }
            })
            //            .refresher(style:.system2 ,config: .init(headerShimMaxHeight: 220)) { done in
            //                Task{
            //                    if let user = try await APIClient.shared.getUserInfo(userId: miniUser.id) {
            //                        self.user = user
            //                        miniUser = .init(id: user.id, firstName: user.firstName, lastName: user.lastName, profilePhotos: user.profilePhotos, occupation: user.occupation, location: user.location, birthDate: user.birthDate)
            //                        try await viewModel.getUserPosts(userId: miniUser.id)
            //                        try await viewModel.getUserClubs(userId: miniUser.id)
            //                        done()
            //                    }
            //                }
            //
            //            }
            .edgesIgnoringSafeArea(.top)
            .frame(maxWidth: .infinity)
            .background(Color("testColor"))
            .navigationBarBackButtonHidden(true)
            
            navbar()
        }
        .swipeBack()
        .sheet(isPresented: $showRemoveSheet, content: {
            AutoSizeSheetView{
                OneButtonResponseSheet(onClick: {
                    Task {
                        if let user = self.user, try await APIClient.shared.removeFriend(removeUserId: user.id) != nil {
                            self.user?.currentFriendshipStatus = .NOT_FRIENDS
                            showRemoveSheet = false
                        }
                    }
                }, buttonText: "Remove Friend", image: Image(systemName: "x.circle.fill"))
            }
            .presentationDragIndicator(.visible)
        })
        
        .sheet(isPresented: $showCancelSheet, content: {
            AutoSizeSheetView{
                OneButtonResponseSheet(onClick: {
                    Task {
                        if let user = self.user, try await APIClient.shared.removeFriendRequest(removeUserId: user.id) != nil {
                            self.user?.currentFriendshipStatus = .NOT_FRIENDS
                            showCancelSheet = false
                        }
                    }
                }, buttonText: "Cancel Response", image: Image(systemName: "x.circle.fill"))
            }
            .presentationDragIndicator(.visible)
        })
        .sheet(isPresented: $showRespondSheet, content: {
            AutoSizeSheetView{
                AcceptDenySheet(showRespondSheet: $showRespondSheet, user: $user, id: miniUser.id)
            }
            .presentationDragIndicator(.visible)
        })
        .sheet(isPresented: $showSheet, content: {
            CreateSheetView(showSheet: $showSheet, showCreateEvent: $showCreateEvent, showCreateClub: $showCreateClub)
        })
        .sheet(isPresented: $showReportSheet, content: {
            ReportUserView(user: miniUser)
        })
        .fullScreenCover(isPresented: $showCreateClub, content: {
            CreateClubView(resetClubsOnCreate: {
                Task{
                    if let user = user {
                        try await viewModel.getUserClubs(userId: user.id)
                    }
                }
            })
        })
        .fullScreenCover(isPresented: $showCreateEvent, content: {
            CreateEventView()
        })
        .onChange(of: user, { oldValue, newValue in
            if let response = newValue{
                self.miniUser = .init(id: response.id, firstName: response.firstName, lastName: response.lastName, profilePhotos: response.profilePhotos, occupation: response.occupation, location: response.location, birthDate: response.birthDate)
            }
        })
        .onChange(of: websocket.newNotification){ old, new in
            print("triggered 1")
            if let not = new {
                print("triggered 2")
                viewModel.updateUser(not: not, user: $user)
            }
        }
        .onAppear(){
            if Init {
                if let user = userVm.currentUser, miniUser.id != user.id {
                    Task {
                        await fetchAll()
                        
                        Init = false
                    }
                } else {
                    user = userVm.currentUser
                    Task{
                        await viewModel.fetchAllData(userId: miniUser.id)
                    }
                    Init = false
                }
                
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
            } else {
                Menu{
                    ShareLink(item: URL(string: "https://www.youtube.com/")!) {
                        Text("Share via")
                    }
                    
                    Button{
                        showReportSheet = true
                    } label:{
                        Text("Report")
                            .foregroundStyle(.red)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                        .navButton3()
                }
            }
        }
        .padding(.horizontal)
    }
    
    func fetchAll() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    if let response = try await APIClient.shared.getUserInfo(userId: miniUser.id) {
                        DispatchQueue.main.async {
                            self.user = response

                        }
                    }
                    
                } catch {
                    print("Error fetching user posts: \(error)")
                }
            }
            
            group.addTask {
                do {
                    try await viewModel.getUserPosts(userId: miniUser.id)
                } catch {
                    print("Error fetching user posts: \(error)")
                }
            }
            
            group.addTask {
                do {
                    try await viewModel.getUserClubs(userId: miniUser.id)
                } catch {
                    print("Error fetching user clubs: \(error)")
                }
            }
        }
    }
}

#Preview {
    UserProfileView(miniUser: MockMiniUser, user: MockUser)
        .environmentObject(UserViewModel())
        .environmentObject(WebSocketManager())
}
