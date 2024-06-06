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
    
    @State var showSheet: Bool = false
    @State var showCreateEvent: Bool = false
    @State var showCreateClub: Bool = false
    
    @StateObject var viewModel = ProfileViewModel()
    
    @State var showRespondSheet = false
    @State var showRemoveSheet = false
    @State var showCancelSheet = false
    
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
                        
                        
                        HStack(spacing: 5){
                            Image(systemName: "mappin.circle")
                            
                            Text(user?.location.name)
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                        }
                        .foregroundColor(.gray)
                        
                        
                    }.padding()
                    
                    HStack(alignment: .top, spacing: 0
                    ) {
                        UserStats(value: String(Int(user?.friendsCount ?? 0)), title: "Friends")
                            .frame(width: 105)
                        Divider()
                            .frame(height: 50)
                        UserStats(value: String(Int(user?.participatedPostsCount ?? 0)), title: "Events")
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
                
                BadgesTab()
                
                AboutTab(user: user)
                
                if let user = user {
                    EventTab(userID: user.id, posts: $viewModel.posts, createEvent: $showCreateEvent)
                        .onAppear(){
                            Task{
                                try await viewModel.getUserPosts(userId: user.id)
//                                try await viewModel.getUserClubs(userId: user.id)
                            }
                        }
                    if viewModel.clubs.count > 0 {
                        ClubsTab(userID: miniUser.id, clubs:  $viewModel.clubs)
                    }
                }
                
            }
            .refreshable(action: {
                Task{
                    if let user = try await APIClient.shared.getUserInfo(userId: miniUser.id) {
                        self.user = user
                        miniUser = .init(id: user.id, firstName: user.firstName, lastName: user.lastName, profilePhotos: user.profilePhotos, occupation: user.occupation, location: user.location, birthDate: user.birthDate)
                        try await viewModel.getUserPosts(userId: miniUser.id)
//                        try await viewModel.getUserClubs(userId: miniUser.id)
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
            .navigationBarBackButtonHidden(true)
            
            navbar()
        }
        .sheet(isPresented: $showRemoveSheet, content: {
            VStack(alignment: .leading){
                Button{
                    Task {
                        if let user = self.user, try await APIClient.shared.removeFriend(removeUserId: user.id) != nil {
                            self.user?.currentFriendshipStatus = .NOT_FRIENDS
                            showRespondSheet = false
                        }
                    }
                } label: {
                    HStack{
                        Image(systemName: "x.circle.fill")
                            .frame(width: 35, height: 35)
                            .foregroundStyle(Color("main-secondary-color"))
                        
                        Text("Remove Friend")
                            .fontWeight(.semibold)
                    }
                }
            }
            .presentationDetents([.height(150)])
            .presentationDragIndicator(.visible)
        })
        
        .sheet(isPresented: $showCancelSheet, content: {
            VStack(alignment: .leading){
                Button{
                    Task {
                        if let user = self.user, try await APIClient.shared.removeFriendRequest(removeUserId: user.id) != nil {
                            self.user?.currentFriendshipStatus = .NOT_FRIENDS
                            showRespondSheet = false
                        }
                    }
                } label: {
                    HStack{
                        Image(systemName: "x.circle.fill")
                            .frame(width: 35, height: 35)
                            .foregroundStyle(Color("main-secondary-color"))
                        
                        Text("Cancel Response")
                            .fontWeight(.semibold)
                    }
                }
            }
            .presentationDetents([.height(150)])
            .presentationDragIndicator(.visible)
        })
        .sheet(isPresented: $showRespondSheet, content: {
            VStack(alignment: .leading){
                Button{
                    Task {
                        if try await APIClient.shared.respondToFriendRequest(toUserId: miniUser.id, action:.ACCEPT) != nil {
                            self.user?.currentFriendshipStatus = .FRIENDS
                            showRespondSheet = false
                        }
                    }
                } label: {
                    HStack{
                        Image(systemName: "checkmark.circle.fill")
                            .frame(width: 35, height: 35)
                            .foregroundStyle(Color("main-secondary-color"))
                        
                        Text("Accept")
                            .fontWeight(.semibold)
                    }
                }
                
                Button{
                    Task {
                        if try await APIClient.shared.respondToFriendRequest(toUserId: miniUser.id, action:.DENY) != nil {
                            self.user?.currentFriendshipStatus = .NOT_FRIENDS
                            showRespondSheet = false
                        }
                    }
                } label: {
                    HStack{
                        Image(systemName: "x.circle.fill")
                            .frame(width: 35, height: 35)
                            .foregroundStyle(Color("main-secondary-color"))
                        
                        Text("Deny")
                            .fontWeight(.semibold)
                    }
                }
            }
            .presentationDetents([.height(250)])
            .presentationDragIndicator(.visible)
        })
        .sheet(isPresented: $showSheet, content: {
            CreateSheetView(showSheet: $showSheet, showCreateEvent: $showCreateEvent, showCreateClub: $showCreateClub)
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
