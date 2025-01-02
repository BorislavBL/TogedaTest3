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
    @EnvironmentObject var clubsViewModel: ClubsViewModel
    
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
                    
                    InboxView()
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
                    navigationManager.isPresentingEvent = true
                    navigationManager.screen = navigationManager.oldScreen
                } else if (navigationManager.isPresentingEvent == false) {
                    navigationManager.oldScreen = newValue
                }
            }
            .fullScreenCover(isPresented: $navigationManager.isPresentingClub) {
                CreateClubView(resetClubsOnCreate: {})
            }
//            .fullScreenCover(isPresented: $locationManager.showLocationServicesView, content: {
//                AllowLocationView()
//            })
            .sheet(isPresented: $postsViewModel.showReportEvent, content: {
                ReportEventView(event: postsViewModel.clickedPost, isActive: $postsViewModel.showReportEvent)
            })
            .sheet(isPresented: $clubsViewModel.showReport, content: {
                ReportClubView(club: clubsViewModel.clickedClub, isActive: $clubsViewModel.showReport)
            })
            .sheet(isPresented: $postsViewModel.showSharePostSheet) {
                ShareView(post: postsViewModel.clickedPost)
                    .presentationDetents([.fraction(0.8), .fraction(1)])
                    .presentationDragIndicator(.visible)
                
            }
            .sheet(isPresented: $clubsViewModel.showShareClubSheet) {
                ShareView(club: clubsViewModel.clickedClub)
                    .presentationDetents([.fraction(0.8), .fraction(1)])
                    .presentationDragIndicator(.visible)
                
            }
            .navigationDestination(for: SelectionPath.self, destination: { state in
                switch state {
                case.eventDetails(let post):
                    EventView(post: post)
                case .usersList(post: let post):
                    UsersListView(post: post)
                case .eventUserJoinRequests(post: let post):
                    UserJoinRequestsView(post: post)
                case .completedEventDetails(post: let post):
                    CompletedEventView(post: post)
                case .allUserEvents(userID: let userID):
                    AllUserEventsView(userID: userID)
                case .bookmarkedEvents(userID: let userID):
                    BookmarkedEventsView(userID: userID)
                case .profile(let miniUser):
                    UserProfileView(miniUser: miniUser)
                case .userSettings(let isSupportNeeded):
                    UserSettingsView(isSupportNeeded: isSupportNeeded)
                case .userFriendsList(let user):
                    FriendsListView(user: user)
                case .userFriendRequestsList:
                    FriendsRequestsView()
                case .editProfile:
                    EditProfileView()
                case .editProfilePhoneNumberMain:
                    EditProfilePhoneNumberMainView()
                case .editProfilePhoneNumber:
                    EditProfilePhoneNumberView()
                case .editProfilePhoneCodeVerification:
                    EditProfilePhoneCodeVerificationView()
                case .club(let club):
                    ClubView(club: club)
                case .clubJoinRequests(let club):
                    ClubJoinRequestsView(club: club)
                case .eventWaitingList(let post):
                    UserWaitingListView(post: post)
                case .allClubEventsView(let clubId):
                    AllClubEventsView(clubId: clubId)
                case .allUserGroups(userID: let userID):
                    AllUserGroupsView(userID: userID)
                case .clubMemersList(let club):
                    ClubMembersListView(club: club)
                case .userChat(chatroom: let chatroom):
                    ChatView(chatRoom: chatroom)
                case .notification:
                    NotificationView()
                case .userRequest:
                    UserRequestView()
//                case .eventReview(post: let post):
//                    EventReviewView(post: post)
//                case .reviewMemories:
//                    ReviewMemoriesView()
//                case .rateParticipants(post: let post, rating: let rating):
//                    RateParticipantsView(post: post, rating: rating)
                case .userReviewView(user: let user):
                    ReviewProfileView(user: user)
                case .paymentPage:
                    CreateStripeView()
                case .chatParticipants(chatroom: let chatroom):
                    ChatParticipantsView(chatRoom: chatroom)
                case .changePassword:
                    ChangePasswordView()
                case .blockedUsers:
                    BlockedUsersView()
                case .groupSettingsView(chatroom: let chatroom):
                    GroupSettingsView(chatroom: chatroom)
                case .editGroupChat(chatroom: let chatroom):
                    EditGroupView(chatRoom: chatroom)
                case .test:
                    TestView()

                }
            })
        }
        
    }
    
}


struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(PostsViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(ClubsViewModel())
            .environmentObject(ContentViewModel())
            .environmentObject(NavigationManager())
            .environmentObject(LocationManager())
    }
}
