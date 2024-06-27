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
                    
                    ShareLink(item: URL(string: "https://www.youtube.com/")!) {
                        Text("Share via")
                    }
                    
                    if let user = userViewModel.currentUser, user.id == postsViewModel.clickedPost.owner.id {
                        
                    } else {
                        Button("Report") {
                            postsViewModel.showPostOptions = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                postsViewModel.showReportEvent = true
                            }
                        }
                    }
                    
                }
                .presentationDetents([.fraction(0.25)])
                .presentationDragIndicator(.visible)
                .scrollDisabled(true)
            })
            .sheet(isPresented: $postsViewModel.showReportEvent, content: {
                ReportEventView(event: postsViewModel.clickedPost)
            })
            .sheet(isPresented: $clubsViewModel.showOption, content: {
                List{
                    ShareLink(item: URL(string: "https://www.youtube.com/")!) {
                        Text("Share via")
                    }
                    
                    if let user = userViewModel.currentUser, user.id == clubsViewModel.clickedClub.owner.id {
                        Button{
                            clubsViewModel.showOption = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                clubsViewModel.showReport = true
                            }
                        } label:{
                            Text("Report")
                                .foregroundStyle(.red)
                        }
                    }
                }
                .scrollDisabled(true)
                .presentationDetents([.height(200)])
            })
            .sheet(isPresented: $clubsViewModel.showReport, content: {
                ReportClubView(club: clubsViewModel.clickedClub)
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
                case .usersList(let post):
                    UsersListView(eventVM: EventViewModel(), post: post)
                    //                case .editEvent(post: let post):
                    //                    EditEventView(post: post)
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
                    GroupView(club: club)
                case .clubJoinRequests(let club):
                    GroupJoinRequestsView(club: club)
//                case .editClubView(let club):
//                    EditGroupView(club: club)
                case .allClubEventsView(let clubId):
                    AllGroupEventsView(clubId: clubId)
                case .allUserGroups(userID: let userID):
                    AllUserGroupsView(userID: userID)
                case .clubMemersList(let club):
                    GroupMembersListView(club: club)
                case .userChat(user: let user):
                    ChatView(user: user)
                case .notification:
                    NotificationView()
                case .userRequest:
                    UserRequestView()
                case .eventReview(let post):
                    EventReviewView(post: post)
                case .reviewMemories:
                    ReviewMemoriesView()
                case .test:
                    TestView()
                case .userFriendsList(let user):
                    FriendsListView(user: user)
                case .userFriendRequestsList:
                    FriendsRequestsView()
                case .rateParticipants(post: let post, rating: let rating):
                    RateParticipantsView(post: post, rating: rating)
                case .eventWaitingList(let post):
                    UserWaitingListView(post: post)
                case .userReviewView(user: let user):
                    ReviewProfileView(user: user)
                case .paymentPage:
                    CreateStripeView()
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
