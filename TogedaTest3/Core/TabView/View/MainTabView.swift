//
//  MainTabView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var contentViewModel: ContentViewModel
    @EnvironmentObject var postsViewModel: PostsViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
    
    @StateObject var chatVM = ChatViewModel()
    
    var body: some View {
        NavigationStack(path: $navigationManager.selectionPath){
            Group{
                TabView(selection: $navigationManager.screen) {
                    HomeView()
                        .tag(Screen.home)
                        .tabItem {
                            Image(systemName: "house")
                        }
                    MapView()
                        .tag(Screen.map)
                        .tabItem {
                            Image(systemName: "map.fill")
                        }
                    
                    Button("Any") {
                        navigationManager.change(to: Screen.home)
                    }
                    .tag(Screen.add)
                    .tabItem {
                        Image(systemName: "plus.square")
                    }
                    InboxView(chatVM: chatVM)
                        .tag(Screen.message)
                        .tabItem {
                            Image(systemName: "message")
                        }
                    ProfileView()
                        .tag(Screen.profile)
                        .tabItem {
                            Image(systemName: "person.circle")
                        }
                    
                    
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithDefaultBackground()
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
//                contentViewModel.userViewModel = userViewModel
            }
            .onChange(of: navigationManager.screen) { oldValue, newValue in
                if navigationManager.screen == .add {
                    navigationManager.isPresenting = true
                    navigationManager.screen = navigationManager.oldScreen
                } else if (navigationManager.isPresenting == false) {
                    navigationManager.oldScreen = newValue
                }
            }
            .fullScreenCover(isPresented: $navigationManager.isPresenting) {
                CreateEventView()
            }
            .fullScreenCover(isPresented: $locationManager.showLocationServicesView, content: {
                AllowLocationView()
            })
            .sheet(isPresented: $postsViewModel.showPostOptions, content: {
                List {
                    Button("Save") {
                        postsViewModel.selectedOption = "Save"
                    }
                    
                    ShareLink(item: URL(string: "https://www.youtube.com/")!) {
                        Text("Share via")
                    }
                    
                    Button("Report") {
                        postsViewModel.selectedOption = "Report"
                    }
                    
//                    if let user = postsViewModel.posts[postsViewModel.clickedPostIndex].user, user.id == userId {
                        Button("Delete") {
                            postsViewModel.selectedOption = "Delete"
                        }
//                    }
                }
                .presentationDetents([.fraction(0.25)])
                .presentationDragIndicator(.visible)
                .scrollDisabled(true)
            })
            .sheet(isPresented: $postsViewModel.showSharePostSheet) {
                ShareView()
                    .presentationDetents([.fraction(0.8), .fraction(1) ])
                    .presentationDragIndicator(.visible)
            }
            .navigationDestination(isPresented: $chatVM.showChat, destination: {
                if let user = chatVM.selectedUser {
                    ChatView(viewModel: chatVM, user: user)
                }
            })
            .navigationDestination(for: SelectionPath.self, destination: { state in
                switch state {
                case .eventDetails(let post):
                    EventView(post: post)
                case .usersList(users: let users, post: let post):
                    UsersListView(users: users, post: post)
                case .editEvent(post: let post):
                    EditEventView(post: post)
                case .userRequests(users: let users):
                    UserRequestView(users: users)
                case .completedEventDetails(post: let post):
                    CompletedEventView(post: post)
                case .completedEventUsersList:
                    CompletedEventUsersList()
                case .allUserEvents(userID: let userID):
                    AllUserEventsView(userID: userID)
                case .bookmarkedEvents(userID: let userID):
                    BookmarkedEventsView(userID: userID)
                case .profile(let miniUser):
                    UserProfileView(miniUser: miniUser)
                case .userSettings:
                    UserSettingsView()
                case .editProfile:
                    EditProfileView()
                case .editProfilePhoneNumberMain:
                    EditProfilePhoneNumberMainView()
                case .editProfilePhoneNumber:
                    EditProfilePhoneNumberView()
                case .editProfilePhoneCodeVerification:
                    EditProfilePhoneCodeVerificationView()
                case .club(let club):
                    GroupView(clubID: club.id)
                case .allUserGroups(userID: let userID):
                    AllUserGroupsView(userID: userID)
                case .userChat(user: let user):
                    ChatView(user: user)
                case .notification:
                    NotificationView()
                case .userRequest(users: let users):
                    UserRequestView(users: users)
                case .eventReview:
                    EventReviewView()
                case .reviewMemories:
                    ReviewMemoriesView()
                case .test:
                    TestView()
                }
                
            })
            //            .navigationDestination(for: Post.self) { post in
            //                EventView(postID: post.id)
            //            }
            //            .navigationDestination(for: Club.self) { club in
            //                GroupView(clubID: club.id)
            //            }
            //            .navigationDestination(for: MiniUser.self) { user in
            //                UserProfileView(miniUser: user)
            //            }
        }
        
    }
}




struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(PostsViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(ContentViewModel())
            .environmentObject(NavigationManager())
            .environmentObject(LocationManager())
    }
}
