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
    @EnvironmentObject var navManager: NavigationManager
    @EnvironmentObject var postsVM: PostsViewModel
    @EnvironmentObject var activityVM: ActivityViewModel
    @EnvironmentObject var clubsVM: ClubsViewModel
    
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
    @State var showBlockSheet = false
    
    var isCurrentUser: Bool {
        if let user = userVm.currentUser {
            return user.id == miniUser.id
        } else {
            return false
        }
    }
    
    var isFriend: Bool {
        if let user = self.user {
            return user.currentFriendshipStatus == .FRIENDS
        } else {
            return false
        }
    }
    
    var isBlocked: Bool {
        if let user = self.user {
            return user.currentFriendshipStatus == .BLOCKED_BY_YOU || user.currentFriendshipStatus == .BLOCKED_YOU
        } else {
            return false
        }
    }
    
    var isDeleted: Bool {
        if let user = self.user, user.isDeleted {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        ZStack(alignment: .top){
            ScrollView(showsIndicators: false){
                if isBlocked {
                    
                    blockedView()
                    
                } else if isDeleted {
                    deletedView()
                }else {
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
                            HStack(spacing: 5){
                                Text("\(miniUser.firstName) \(miniUser.lastName)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                if let user = self.user {
                                    if user.userRole == .PARTNER {
                                        PartnerSeal()
                                    } else if user.userRole == .AMBASSADOR {
                                        AmbassadorSeal()
                                    }
                                }
                            }
                            
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
                            
                            
                            if let user = self.user {
                                HStack(spacing: 5){
                                    Image(systemName: "mappin.circle")
                                    
                                    Text(user.location.name)
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
                                    UserStats(value: "\(0)", title: "Likes")
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
                                if let user = self.user {
                                    if user.currentFriendshipStatus == .FRIENDS{
                                        Button {
                                            showRemoveSheet = true
                                        } label: {
                                            Text("Friends")
                                                .normalTagTextStyle()
                                                .frame(width: UIScreen.main.bounds.width/2 - 60)
                                                .normalTagRectangleStyle()
                                        }
                                    } else if user.currentFriendshipStatus == .NOT_FRIENDS{
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
                                    } else if user.currentFriendshipStatus == .RECEIVED_FRIEND_REQUEST {
                                        Button {
                                            showRespondSheet = true
                                        } label: {
                                            Text("Respond")
                                                .normalTagTextStyle()
                                                .frame(width: UIScreen.main.bounds.width/2 - 60)
                                                .normalTagRectangleStyle()
                                        }
                                    } else if user.currentFriendshipStatus == .SENT_FRIEND_REQUEST {
                                        Button {
                                            showCancelSheet = true
                                        } label: {
                                            Text("Cancel")
                                                .normalTagTextStyle()
                                                .frame(width: UIScreen.main.bounds.width/2 - 60)
                                                .normalTagRectangleStyle()
                                        }
                                    } else {
                                        Text("Loading...")
                                            .normalTagTextStyle()
                                            .frame(width: UIScreen.main.bounds.width/2 - 60)
                                            .normalTagRectangleStyle()
                                    }
                                } else {
                                    Text("Loading...")
                                        .normalTagTextStyle()
                                        .frame(width: UIScreen.main.bounds.width/2 - 60)
                                        .normalTagRectangleStyle()
                                }
                                
                                if isFriend {
                                    Button {
                                        Task{
                                            if let _user = user, let chatroomID = _user.chatRoomId, let chatRoom = try await APIClient.shared.getChat(chatId: chatroomID) {
                                                navManager.selectionPath = []
                                                navManager.screen = .message
                                                //                                            websocket.selectedUser = _user
                                                navManager.selectionPath.append(SelectionPath.userChat(chatroom: chatRoom))
                                            }
                                        }
                                    } label: {
                                        Text("Message")
                                            .normalTagTextStyle()
                                            .frame(width: UIScreen.main.bounds.width/2 - 60)
                                            .normalTagRectangleStyle()
                                    }
                                } else {
                                    ShareLink(item: URL(string: createURLLink(postID: nil, clubID: nil, userID: miniUser.id))!) {
                                        Text("Share")
                                            .normalTagTextStyle()
                                            .frame(width: UIScreen.main.bounds.width/2 - 60)
                                            .normalTagRectangleStyle()
                                    }
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
                    
                    AboutTab(user: user, badges: viewModel.badges, showInstagram: (isCurrentUser || isFriend))
                    
                    
                    if let currentUser = userVm.currentUser, currentUser.id == miniUser.id || viewModel.posts.count > 0 {
                        EventTab(userID: miniUser.id, posts: $viewModel.posts, createEvent: $showCreateEvent, count: $viewModel.postsCount)
                    }
                    
                    if let currentUser = userVm.currentUser, currentUser.id == miniUser.id || viewModel.clubs.count > 0 {
                        ClubsTab(userID: miniUser.id, count: viewModel.clubsCount, createClub: $showCreateClub, clubs:  $viewModel.clubs)
                    }
                }
                
                
            }
            .refreshable(action: {
                viewModel.posts = []
                viewModel.clubs = []
                Task{
                    if let user = userVm.currentUser, miniUser.id != user.id {
                        await fetchAll()
                    } else {
                        user = userVm.currentUser
                        Task{
                            await viewModel.fetchAllData(userId: miniUser.id, _posts: $userVm.posts, _clubs: $userVm.clubs)
                        }
                    }
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
            .navigationBarHidden(true)
            .navigationBarTitle("")
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
                AcceptDenySheet(showRespondSheet: $showRespondSheet, user: $user, currentUser: userVm.currentUser, id: miniUser.id)
            }
            .presentationDragIndicator(.visible)
        })
        .sheet(isPresented: $showSheet, content: {
            CreateSheetView(showSheet: $showSheet, showCreateEvent: $showCreateEvent, showCreateClub: $showCreateClub)
        })
        .sheet(isPresented: $showReportSheet, content: {
            ReportUserView(user: miniUser, isActive: $showReportSheet)
        })
        .sheet(isPresented: $showBlockSheet, content: {
            VStack(spacing: 30){
                Text("Are you sure you want to block \(miniUser.firstName) \(miniUser.lastName)?")
                    .multilineTextAlignment(.leading)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Button{
                    Task {
                        if let response = try await APIClient.shared.blockUser(userId: miniUser.id){
                            if response {
                                user?.currentFriendshipStatus = .BLOCKED_BY_YOU
                                postsVM.feedPosts.removeAll(where: {$0.owner.id == user?.id})
                                clubsVM.feedClubs.removeAll(where: {$0.owner.id == user?.id})
                            }
                        }
                    }
                } label:{
                    Text("Block")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(.red)
                        .cornerRadius(10)
                }
            }
            .padding()
            .presentationDetents([.fraction(0.25)])
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
                self.miniUser = .init(id: response.id, firstName: response.firstName, lastName: response.lastName, profilePhotos: response.profilePhotos, occupation: response.occupation, location: response.location, birthDate: response.birthDate, userRole: .init(rawValue: response.userRole.rawValue) ?? .NORMAL)
            }
        })
        .onChange(of: websocket.newNotification){ old, new in
            print("Triggered 1")
            if let not = new {
                print("triggered 2")
                viewModel.updateUser(not: not, user: $user)
            }
        }
        .onAppear(){
            if Init {
                print(miniUser.id)
                if let user = userVm.currentUser, miniUser.id != user.id {
                    Task {
                        await fetchAll()
                        Init = false
                    }
                } else {
                    user = userVm.currentUser
                    Task{
                        await viewModel.fetchAllData(userId: miniUser.id, _posts: $userVm.posts, _clubs: $userVm.clubs)
                    }
                    Init = false
                }
                
            }
            else {
                Task{
                    if let user = userVm.currentUser, miniUser.id == user.id {
                        if let response = try await APIClient.shared.getFriendList(userId: user.id, page: 0, size: 2){
                            self.user?.friendsCount = Double(response.listCount)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    
    func blockedView() -> some View {
        VStack{
            VStack(alignment: .center){
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .foregroundStyle(.gray)
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 1.5)
            .background(.white)
            
            VStack(spacing: 10) {
                Text(user?.currentFriendshipStatus == .BLOCKED_BY_YOU ? "Blocked User" : "Unknown User")
                    .font(.title2)
                    .fontWeight(.bold)
                
                WrappingHStack(horizontalSpacing: 5, verticalSpacing: 5){
                    HStack(spacing: 5){
                        Image(systemName: "suitcase")
                        
                        Text("Unknown")
                            .font(.footnote)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.gray)
                    
                    
                    HStack(spacing: 5){
                        Image(systemName: "birthday.cake")
                        
                        Text("Unknown")
                            .font(.footnote)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.gray)
                    
                }
                
                
                
                HStack(spacing: 5){
                    Image(systemName: "mappin.circle")
                    
                    Text("Unknown")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.gray)
                
                
                
            }.padding()
            
            HStack(alignment: .top, spacing: 0
            ) {
                UserStats(value: String(Int(0)), title: "Friends")
                    .frame(width: 105)
                
                
                Divider()
                    .frame(height: 50)
                
                
                UserStats(value: "\(0)", title: "Events")
                    .frame(width: 105)
                
                Divider()
                    .frame(height: 50)
                
                
                VStack{
                    UserStats(value: "\(0)", title: "Likes")
                    Text("0 no shows")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
                .frame(width: 105)
                
                
                
            }
            .padding(.bottom, 8)
            
            if let user = user, user.currentFriendshipStatus == .BLOCKED_BY_YOU {
                Text("You have blocked this user. Go to settings and unblock them if you want to see more.")
                    .font(.footnote)
                    .bold()
                    .foregroundStyle(.gray)
                    .padding()
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.bottom)
        .frame(width: UIScreen.main.bounds.width)
        .background(.bar)
        .cornerRadius(10)
    }
    
    func deletedView() -> some View {
        VStack{
            VStack(alignment: .center){
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .foregroundStyle(.gray)
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 1.5)
            .background(.white)
            
            VStack(spacing: 10) {
                Text("Deleted User")
                    .font(.title2)
                    .fontWeight(.bold)
                
                WrappingHStack(horizontalSpacing: 5, verticalSpacing: 5){
                    HStack(spacing: 5){
                        Image(systemName: "suitcase")
                        
                        Text("Unknown")
                            .font(.footnote)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.gray)
                    
                    
                    HStack(spacing: 5){
                        Image(systemName: "birthday.cake")
                        
                        Text("Unknown")
                            .font(.footnote)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.gray)
                    
                }
                
                
                
                HStack(spacing: 5){
                    Image(systemName: "mappin.circle")
                    
                    Text("Unknown")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.gray)
                
                
                
            }.padding()
            
            HStack(alignment: .top, spacing: 0
            ) {
                UserStats(value: String(Int(0)), title: "Friends")
                    .frame(width: 105)
                
                
                Divider()
                    .frame(height: 50)
                
                
                UserStats(value: "\(0)", title: "Events")
                    .frame(width: 105)
                
                Divider()
                    .frame(height: 50)
                
                
                VStack{
                    UserStats(value: "\(0)", title: "Likes")
                    Text("0 no shows")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
                .frame(width: 105)
                
                
                
            }
            .padding(.bottom, 8)
            
            Text("This User have been deleted.")
                .font(.footnote)
                .bold()
                .foregroundStyle(.gray)
                .padding()
                .multilineTextAlignment(.center)
        }
        .padding(.bottom)
        .frame(width: UIScreen.main.bounds.width)
        .background(.bar)
        .cornerRadius(10)
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
                
                NavigationLink(value: SelectionPath.userSettings(isSupportNeeded: false)) {
                    Image(systemName: "gear")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                        .navButton3()
                }
            } else {
                
                Menu{
                    ShareLink(item: URL(string: createURLLink(postID: nil, clubID: nil, userID: miniUser.id))!) {
                        Text("Share via")
                    }
                    
                    Button{
                        showReportSheet = true
                    } label:{
                        Text("Report")
                            .foregroundStyle(.red)
                    }
                    
                    Button{
                        showBlockSheet = true
                    } label:{
                        Text("Block")
                            .foregroundStyle(.red)
                    }
                    
                    if let currentUser = userVm.currentUser,
                       currentUser.userRole == .ADMINISTRATOR,
                       let user = user, user.userRole != .ADMINISTRATOR{
                        Menu {
                            Button{
                                changeUserStatus(role: .PARTNER)
                            } label:{
                                Text("Partner")
                                    .foregroundStyle(.red)
                            }
                            
                            Button{
                                changeUserStatus(role: .AMBASSADOR)
                            } label:{
                                Text("Ambassador")
                                    .foregroundStyle(.red)
                            }
                            
                            Button{
                                changeUserStatus(role: .NORMAL)
                            } label:{
                                Text("Normal")
                                    .foregroundStyle(.red)
                            }
                        } label: {
                            Text("Change Status")
                        }
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
    
    func changeUserStatus(role: Operations.setUserRole.Input.Query.userRolePayload) {
        Task {
            if let response = try await APIClient.shared.giveUserRole(userId: miniUser.id, role: role) {
                if response {
                    switch role {
                    case .ADMINISTRATOR:
                        print("Admin")
                    case .AMBASSADOR:
                        user?.userRole = .AMBASSADOR
                    case .PARTNER:
                        user?.userRole = .PARTNER
                    case .NORMAL:
                        user?.userRole = .NORMAL
                    }
                }
            }
        }
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
                    if let response = try await APIClient.shared.getBadges(userId: miniUser.id) {
                        if response.count > 0 {
                            DispatchQueue.main.async {
                                viewModel.badges = response
                            }
                        }
                    }
                } catch {
                    print("Error fetching user clubs: \(error)")
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
            
            group.addTask {
                do {
                    if let response = try await APIClient.shared.getUserLikesList(userId: miniUser.id, page: 0, size: 1) {
                        DispatchQueue.main.async {
                            viewModel.likesCount = response.listCount
                        }
                    }
                } catch {
                    print("Error fetching user ликес: \(error)")
                }
            }
        }
    }
}

#Preview {
    UserProfileView(miniUser: MockMiniUser, user: MockUser)
        .environmentObject(UserViewModel())
        .environmentObject(WebSocketManager())
        .environmentObject(NavigationManager())
        .environmentObject(PostsViewModel())
        .environmentObject(ClubsViewModel())
        .environmentObject(ActivityViewModel())
}
