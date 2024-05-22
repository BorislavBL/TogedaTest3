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
    let navbarHeight: CGFloat = 94
    
    @StateObject var viewModel = HomeViewModel()
    @StateObject var filterViewModel = FilterViewModel()
    @EnvironmentObject var postsViewModel: PostsViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var refreshingHeight: CGFloat = 0.0

    var body: some View {
            ZStack{
                Color("testColor")
                    .edgesIgnoringSafeArea(.vertical)
                
                ZStack(alignment: .top) {
                    
                    VStack {
                        Color.clear
                            .frame(height: refreshingHeight)
                        
                        ScrollView(.vertical, showsIndicators: false){
                            LazyVStack (spacing: 10){
                                
                                ForEach(postsViewModel.feedPosts.indices, id: \.self) { index in
                                    PostCell(post: postsViewModel.feedPosts[index])
                                        .onAppear(){
                                            postsViewModel.feedScrollFetch(index: index)
                                        }
                                }
                                GroupCell()
                                
//                                ForEach(viewModel.feedItems, id:\.self) {item in
//                                    switch item {
//                                    case .event(let post):
//                                        PostCell(post: post)
//                                    case .group(let club):
//                                        GroupCell(club: club)
//                                    }
//                                    
//                                }
                                
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
                            viewModel.fetchFeed()
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
                            SearchView(viewModel: viewModel)
                        }
                    }
                    .onChange(of: viewModel.showCancelButton){
                        if viewModel.showCancelButton {
                            postsViewModel.startSearch()
                        } else {
                            postsViewModel.startSearch()
                        }
                    }
                    CustomNavBar(showFilter: $showFilter, filterVM: filterViewModel, homeViewModel: viewModel)
                }
                
            }
            .sheet(isPresented: $postsViewModel.showJoinRequest){
                    JoinRequestView()
            }
            .sheet(isPresented: $filterViewModel.showAllFilter, content: {
                AllInOneFilterView(filterVM: filterViewModel)
//                    .presentationDetents([.fraction(0.99)])
//                    .presentationDragIndicator(.visible)
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


