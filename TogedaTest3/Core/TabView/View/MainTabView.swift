//
//  MainTabView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var router = TabRouter()
    var user: User
    
    @EnvironmentObject var postsViewModel: PostsViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var locationManager: LocationManager
    let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
    
    @StateObject var chatVM = ChatViewModel()
    
    var body: some View {
        NavigationStack{
            TabView(selection: $router.screen) {
                Group {
                    
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
                        router.change(to: Screen.home)
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
                    ProfileView(user: user)
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
            }
            .onChange(of: router.screen) { oldValue, newValue in
                if router.screen == .add {
                    router.isPresenting = true
                    router.screen = router.oldScreen
                } else if (router.isPresenting == false) {
                    router.oldScreen = newValue
                }
            }
            .fullScreenCover(isPresented: $router.isPresenting) {
                CreateEventView()
                //                    .presentationDragIndicator(.hidden)
                //                    .interactiveDismissDisabled(true)
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
                    
                    if let user = postsViewModel.posts[postsViewModel.clickedPostIndex].user, user.id == userId {
                        Button("Delete") {
                            postsViewModel.selectedOption = "Delete"
                        }
                    }
                }
                .presentationDetents([.fraction(0.25)])
                .presentationDragIndicator(.visible)
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
            .navigationDestination(for: Post.self) { post in
                EventView(postID: post.id)
                //.toolbar(.hidden, for: .tabBar)
            }
            .navigationDestination(for: Club.self) { club in
                GroupView(clubID: club.id)
                //.toolbar(.hidden, for: .tabBar)
            }
            .navigationDestination(for: MiniUser.self) { user in
                UserProfileView(miniUser: user)
            }
            //            .fullScreenCover(isPresented: $postsViewModel.showDetailsPage, content: {
            //                EventView(viewModel: postsViewModel, post: postsViewModel.posts[postsViewModel.clickedPostIndex], userViewModel: userViewModel)
            //            })
        }
    }
}




struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(user: User.MOCK_USERS[1])
            .environmentObject(LocationManager())
            .environmentObject(PostsViewModel())
            .environmentObject(UserViewModel())
    }
}
