//
//  HomeView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import Refresher

struct HomeView: View {
    @State var showFilter: Bool = true
    @State private var previousMinY: CGFloat = 0
    let navbarHeight: CGFloat = 94
    
    @StateObject var viewModel = HomeViewModel()
    @StateObject var filterViewModel = FilterViewModel()
    @EnvironmentObject var postsViewModel: PostsViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        ZStack{
            Color("testColor")
                .edgesIgnoringSafeArea(.vertical)
            
            ZStack(alignment: .top) {
                
                VStack {
                    
                    ScrollView(.vertical, showsIndicators: false){
                        LazyVStack (spacing: 10){
                            if postsViewModel.feedPosts.count > 0 {
                                ForEach(Array(postsViewModel.feedPosts.enumerated()), id: \.element.id) {index, post in
                                    PostCell(post: post)
                                        .onAppear(){
                                            postsViewModel.feedScrollFetch(index: index)
                                        }
                                }
                                ClubCell()
                                
                                if postsViewModel.isLoading {
                                    PostSkeleton() // Show spinner while loading
                                } else {
                                    VStack(spacing: 8){
                                        Divider()
                                        Text("No more posts")
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.gray)
                                    }
                                    .padding()
                                }
                                
                            } else {
                                ForEach(0..<5, id: \.self) { index in
                                    PostSkeleton()
                                }
                            }
                            
                            
                            
                            
                            //                                ForEach(viewModel.feedItems, id:\.self) {item in
                            //                                    switch item {
                            //                                    case .event(let post):
                            //                                        PostCell(post: post)
                            //                                    case .group(let club):
                            //                                        GroupCell(club: club)
                            //                                    }
                            //
                            //                                }
                            
                            
                            
                            Rectangle()
                                .frame(width: 0, height: 0)
                                .onAppear {
                                    if !postsViewModel.lastPage{
                                        postsViewModel.isLoading = true
                                        Task{
                                            try await postsViewModel.fetchPosts()
                                            postsViewModel.isLoading = false
                                            
                                        }
                                    }
                                }
                        }
                        .padding(.top, navbarHeight - 10)
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
                    .refresher(config: .init(headerShimMaxHeight: 110), refreshView: HomeEmojiRefreshView.init) { done in
                        Task{
                            postsViewModel.feedPosts = []
                            postsViewModel.page = 0
                            try await postsViewModel.fetchPosts()
                            done()
                        }

                    }
                }
                .overlay{
                    if viewModel.showCancelButton {
                        SearchView(viewModel: viewModel)
                    }
                }
                .onChange(of: viewModel.showCancelButton){
                    if viewModel.showCancelButton {
                        viewModel.startSearch()
                    } else {
                        viewModel.stopSearch()
                    }
                }
                CustomNavBar(showFilter: $showFilter, filterVM: filterViewModel, homeViewModel: viewModel)
            }
            
        }
        .sheet(isPresented: $postsViewModel.showJoinRequest){
            JoinRequestView(post: $postsViewModel.clickedPost)
        }
        .sheet(isPresented: $filterViewModel.showAllFilter, content: {
            AllInOneFilterView(filterVM: filterViewModel)
        })
        
    }
    
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(LocationManager())
            .environmentObject(PostsViewModel())
            .environmentObject(UserViewModel())
    }
}


