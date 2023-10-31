//
//  HomeView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct HomeView: View {
    @State var showFilter: Bool = true
    @State private var previousMinY: CGFloat = 0
    @State private var height: CGFloat = 94
    let navbarHeight: CGFloat = 94
    
    @StateObject var viewModel = HomeViewModel()
    @StateObject var filterViewModel = FilterViewModel()
    @ObservedObject var postsViewModel: PostsViewModel
    @ObservedObject var userViewModel: UserViewModel
    
    @State private var refreshingHeight:CGFloat = 0.0
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color("testColor")
                    .edgesIgnoringSafeArea(.vertical)
                
                ZStack(alignment: .top) {
                    
                    VStack {
                        Color.clear
                            .frame(height: refreshingHeight)
                        
                        ScrollView(.vertical, showsIndicators: false){
                            LazyVStack (spacing: 10){
                                ForEach(postsViewModel.posts, id: \.id) { post in
                                    PostCell(viewModel: postsViewModel, post: post, userViewModel: userViewModel)
                                }
                                
                                if postsViewModel.isLoading {
                                    ProgressView() // Show spinner while loading
                                }
                                
                                Rectangle()
                                    .frame(width: 0, height: 0)
                                    .onAppear {
                                        postsViewModel.isLoading = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            postsViewModel.isLoading = false
                                        }
                                    }
                            }
                            .padding(.top, navbarHeight - 15)
                            .padding(.vertical)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .frame(width: 0, height: 0)
                                        .onChange(of: geo.frame(in: .global).minY) { oldMinY,  newMinY in
                                            if newMinY < previousMinY && showFilter && newMinY < 0 {
                                                DispatchQueue.main.async {
                                                    withAnimation {
                                                        showFilter = false
                                                    }
                                                }
                                            } else if newMinY > previousMinY && !showFilter{
                                                DispatchQueue.main.async {
                                                    withAnimation {
                                                        showFilter = true
                                                    }
                                                }
                                            }
                                            
                                            // Update the previous value
                                            previousMinY = newMinY
                                        }
                                }
                            )
                        }
                        .onAppear{
                            postsViewModel.fetchPosts()
                        }
                        .refreshable {
                            print("feeling kinda refreshed")
                            refreshingHeight = navbarHeight
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation(.linear(duration: 0.1)) {
                                    refreshingHeight = 0
                                }
                            }
                        }
                    }
                    .overlay{
                        if viewModel.showCancelButton {
                            SearchView(viewModel: viewModel, postsViewModel: postsViewModel, userViewModel: userViewModel)
                        }
                    }
                    .onChange(of: viewModel.searchText){
                        if !viewModel.searchText.isEmpty {
                            viewModel.searchPostResults = Post.MOCK_POSTS.filter{ result in
                                result.title.lowercased().contains(viewModel.searchText.lowercased())
                            }
                            viewModel.searchUserResults = User.MOCK_USERS.filter{result in
                                result.fullname.lowercased().contains(viewModel.searchText.lowercased())
                            }
                        } else {
                            viewModel.searchPostResults = Post.MOCK_POSTS
                            viewModel.searchUserResults = User.MOCK_USERS
                        }
                    }
                    CustomNavBar(showFilter: $showFilter, viewModel: filterViewModel, postViewModel: postsViewModel, userViewModel: userViewModel, homeViewModel: viewModel)
                        .anchorPreference(key:HeaderBoundsKey.self, value:.bounds) {$0}
                        .overlayPreferenceValue(HeaderBoundsKey.self) { value in
                            GeometryReader{proxy in
                                if let anchor = value {
                                    Color.clear
                                        .onAppear{
                                            height = proxy[anchor].height
                                        }
                                }
                            }
                        }
                }
                
            }
            .sheet(isPresented: $postsViewModel.showJoinRequest){
                JoinRequestView(postsViewModel: postsViewModel, userViewModel: userViewModel)
            }
            .sheet(isPresented: $filterViewModel.filterIsSelected) {
                FilterView(filterViewModel: filterViewModel)
            }
            .navigationDestination(for: Post.self) { post in
                EventView(viewModel: postsViewModel, post: post, userViewModel: userViewModel)
                //.toolbar(.hidden, for: .tabBar)
            }
            .navigationDestination(for: MiniUser.self) { user in
                UserProfileView(miniUser: user)
            }
        }
        
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(postsViewModel: PostsViewModel(), userViewModel: UserViewModel())
    }
}


