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
    
    let locationManager = LocationManager()
    
    @StateObject var postsViewModel = PostsViewModel()
    @StateObject var userViewModel = UserViewModel()
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            TabView(selection: $router.screen) {
                Group {
                    HomeView(postsViewModel: postsViewModel, userViewModel: userViewModel)
                        .tag(Screen.home)
                        .tabItem {
                            Image(systemName: "house")
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
                    Text("Messenger")
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
            .onChange(of: router.screen) { oldValue, newValue in
                if router.screen == .add {
                    router.isPresenting = true
                    router.screen = router.oldScreen
                } else if (router.isPresenting == false) {
                    router.oldScreen = newValue
                }
            }
            .sheet(isPresented: $router.isPresenting) {
                CreateEventView()
                    .presentationDragIndicator(.visible)
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
                }
                .presentationDetents([.fraction(0.4)])
                .presentationDragIndicator(.visible)
            })
            .fullScreenCover(isPresented: $postsViewModel.showDetailsPage, content: {
                EventView(viewModel: postsViewModel, post: postsViewModel.posts[postsViewModel.clickedPostIndex], userViewModel: userViewModel)
            })
        }
    }
    
}




struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(user: User.MOCK_USERS[1])
    }
}
