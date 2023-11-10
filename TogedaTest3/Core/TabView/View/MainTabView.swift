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
    
    @StateObject var postsViewModel = PostsViewModel()
    @StateObject var userViewModel = UserViewModel()
    @EnvironmentObject var locationManager: LocationManager
    let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
    
    var body: some View {
        NavigationStack{
            TabView(selection: $router.screen) {
                Group {
                    if locationManager.showLocationServicesView{
                        AllowLocationView()
                            .tag(Screen.home)
                            .tabItem {
                                Image(systemName: "house")
                            }
                    } else {
                        HomeView(postsViewModel: postsViewModel, userViewModel: userViewModel)
                            .tag(Screen.home)
                            .tabItem {
                                Image(systemName: "house")
                            }
                    }
                    MapView(postsViewModel: postsViewModel, userViewModel: userViewModel)
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
                    InboxView()
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
            .sheet(isPresented: $postsViewModel.showPostOptions, content: {
                List {
                    Button("Save") {
                        postsViewModel.selectedOption = "Save"
                    }
                    
                    Button("Share via") {
                        postsViewModel.selectedOption = "Share"
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
                .presentationDetents([.fraction(0.4)])
                .presentationDragIndicator(.visible)
            })
            .navigationDestination(for: Post.self) { post in
                EventView(viewModel: postsViewModel, post: post, userViewModel: userViewModel)
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
    }
}
