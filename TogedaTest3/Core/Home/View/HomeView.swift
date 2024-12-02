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
    @StateObject var viewModel = HomeViewModel()
    @StateObject var filterViewModel = FilterViewModel()
    @EnvironmentObject var postsViewModel: PostsViewModel
    @EnvironmentObject var clubsVM: ClubsViewModel
    @EnvironmentObject var activityVM: ActivityViewModel
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        ZStack{
            Color("testColor")
                .edgesIgnoringSafeArea(.vertical)
            
            ZStack(alignment: .top) {
//                Test2View(showFilter: $showFilter, filterViewModel: filterViewModel, viewModel: viewModel)

                if locationManager.showLocationServicesView {
                    AllowLocationView()
                        .ignoresSafeArea(.keyboard)
                        .overlay{
                            if viewModel.showCancelButton {
                                SearchView(viewModel: viewModel)
                            }
                        }
                } else {
                    TabView(selection: $filterViewModel.selectedType) {
                        EventsFeedView(showFilter: $showFilter, filterViewModel: filterViewModel, viewModel: viewModel)
                            .tag(FeedType.events)
                        
                        ClubsFeedView(showFilter: $showFilter, filterViewModel: filterViewModel, viewModel: viewModel)
                            .tag(FeedType.clubs)
                            .onAppear(){
                                print("Appear CLub")
                                if clubsVM.feedClubs.count == 0 {
                                    Task{
                                        clubsVM.page = 0
                                        clubsVM.lastPage = true
                                        try await clubsVM.fetchClubs()
                                    }
                                }
                            }
                        
                        FriendsFeedView(showFilter: $showFilter, filterViewModel: filterViewModel, viewModel: viewModel)
                            .tag(FeedType.friends)
                            .onAppear(){
                                print("Appear Activity")
                                if activityVM.activityFeed.count == 0 {
                                    Task{
                                        activityVM.page = 0
                                        activityVM.lastPage = true
                                        try await activityVM.fetchFeed()
                                    }
                                }
                            }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .ignoresSafeArea()
                    .overlay{
                        if viewModel.showCancelButton {
                            SearchView(viewModel: viewModel)
                        }
                    }
                }


                CustomNavBar(showFilter: $showFilter, filterVM: filterViewModel, homeViewModel: viewModel, showLocationServicesView: $locationManager.showLocationServicesView)
            }
            .onChange(of: filterViewModel.selectedType) {
                withAnimation{
                    showFilter = true
                }
            }
            .onChange(of: viewModel.showCancelButton){
                if viewModel.showCancelButton {
                    viewModel.startSearch()
                } else {
                    viewModel.stopSearch()
                }
            }
            .onChange(of: networkManager.isDisconected) { oldValue, newValue in
                if newValue {
                    if postsViewModel.state == .loading, postsViewModel.feedPosts.count == 0 {
                        postsViewModel.state = .refresh
                    }
                    if clubsVM.state == .loading, clubsVM.feedClubs.count == 0 {
                        clubsVM.state = .refresh
                    }
                    if activityVM.state == .loading, activityVM.activityFeed.count == 0 {
                        activityVM.state = .refresh
                    }
                }
            }
            
        }
        .sheet(isPresented: $postsViewModel.showJoinRequest){
            JoinRequestView(post: $postsViewModel.clickedPost, isActive: $postsViewModel.showJoinRequest, refreshParticipants: {})
        }
        .sheet(isPresented: $postsViewModel.showPaymentView){
            if postsViewModel.clickedPost.payment > 0, let max = postsViewModel.clickedPost.maximumPeople, postsViewModel.clickedPost.participantsCount >= max {
                VStack(spacing: 15){
                    Text("😤")
                        .font(.custom("image", fixedSize: 120))
                    
                    Text("The event has reached its maximum capacity.\n Check again later...")
                        .font(.body)
                        .foregroundStyle(.gray)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                }
            } else {
                EventCheckoutSheet(post: $postsViewModel.clickedPost, isActive: $postsViewModel.showPaymentView, refreshParticipants: {})
            }
        }
        .sheet(isPresented: $clubsVM.showJoinClubSheet){
            JoinRequestClubView(club: $clubsVM.clickedClub, isActive: $clubsVM.showJoinClubSheet, refreshParticipants: {})
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
            .environmentObject(ClubsViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(NavigationManager())
            .environmentObject(ActivityViewModel())
            .environmentObject(NetworkManager())

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


//struct PrevHomeView: View {
//    @State var showFilter: Bool = true
//    @State private var previousMinY: CGFloat = 0
//    let navbarHeight: CGFloat = 94
//    @State var isLoading: Bool = false
//
//    @StateObject var viewModel = HomeViewModel()
//    @StateObject var filterViewModel = FilterViewModel()
//    @EnvironmentObject var postsViewModel: PostsViewModel
//    @EnvironmentObject var userViewModel: UserViewModel
//    @EnvironmentObject var clubsVM: ClubsViewModel
//    @EnvironmentObject var navManager: NavigationManager
//    @FocusState private var focus: Bool
//
//    var body: some View {
//        ZStack{
//            Color("testColor")
//                .edgesIgnoringSafeArea(.vertical)
//
//            ZStack(alignment: .top) {
//                ScrollViewReader { proxy in
//                    ScrollView(.vertical, showsIndicators: false){
//                        LazyVStack (spacing: 10){
//                            Color.clear
//                                .frame(height: 74)
//                                .id("Top")
//
//                            switch filterViewModel.selectedType{
//                            case .events:
//                                if postsViewModel.feedPosts.count > 0 {
//                                    ForEach(Array(postsViewModel.feedPosts.enumerated()), id: \.element.id) {index, post in
//                                        PostCell(post: post)
//                                        //                                            .id(post.id)
//                                            .onAppear(){
//                                                postsViewModel.feedScrollFetch(index: index)
//                                            }
//                                    }
//
//                                    if isLoading {
//                                        PostSkeleton() // Show spinner while loading
//                                    } else {
//                                        VStack(spacing: 8){
//                                            Divider()
//                                            Text("No more posts")
//                                                .fontWeight(.semibold)
//                                                .foregroundStyle(.gray)
//
//                                        }
//                                        .padding()
//                                    }
//
//                                } else {
//                                    ForEach(0..<5, id: \.self) { index in
//                                        PostSkeleton()
//                                    }
//                                }
//                            case .clubs:
//                                if clubsVM.feedClubs.count > 0 {
//                                    ForEach(Array(clubsVM.feedClubs.enumerated()), id: \.element.id) {index, club in
//                                        ClubCell(club: club)
//                                        //                                            .id(club.id)
//                                            .onAppear(){
//                                                clubsVM.feedScrollFetch(index: index)
//                                            }
//                                    }
//
//                                    if isLoading {
//                                        PostSkeleton() // Show spinner while loading
//                                    } else {
//                                        VStack(spacing: 8){
//                                            Divider()
//                                            Text("No more clubs")
//                                                .fontWeight(.semibold)
//                                                .foregroundStyle(.gray)
//
//                                        }
//                                        .padding()
//                                    }
//
//                                } else {
//                                    ForEach(0..<5, id: \.self) { index in
//                                        PostSkeleton()
//                                    }
//                                }
//                            case .friends:
//                                Text("")
//                            }
//
//                            Rectangle()
//                                .frame(width: 0, height: 0)
//                                .onAppear {
//                                    switch filterViewModel.selectedType{
//                                    case .events:
//                                        if !postsViewModel.lastPage{
//                                            isLoading = true
//                                            Task{
//                                                try await postsViewModel.fetchPosts()
//                                                isLoading = false
//
//                                            }
//                                        }
//                                    case .clubs:
//                                        if !clubsVM.lastPage {
//                                            isLoading = true
//                                            Task{
//                                                try await clubsVM.fetchClubs()
//                                                isLoading = false
//
//                                            }
//                                        }
//                                    case .friends:
//                                        break
//                                    }
//
//                                }
//                        }
//                        //                        .padding(.top, navbarHeight - 20)
//                        .padding(.vertical)
//                        .background(
//                            GeometryReader { geo in
//                                Color.clear
//                                    .frame(width: 0, height: 0)
//                                    .onChange(of: geo.frame(in: .global).minY) { oldMinY,  newMinY in
//                                        if newMinY < previousMinY && showFilter && newMinY < 0 {
//                                            DispatchQueue.main.async {
//                                                withAnimation {
//                                                    showFilter = false
//                                                }
//                                            }
//                                        } else if newMinY > previousMinY && !showFilter{
//                                            DispatchQueue.main.async {
//                                                withAnimation {
//                                                    showFilter = true
//                                                }
//                                            }
//                                        }
//
//                                        // Update the previous value
//                                        previousMinY = newMinY
//                                    }
//                            }
//                        )
//
//                    }
//                    .refresher(config: .init(headerShimMaxHeight: 110), refreshView: HomeEmojiRefreshView.init) { done in
//                        Task{
//                            switch filterViewModel.selectedType {
//
//                            case .events:
//                                postsViewModel.feedPosts = []
//                                postsViewModel.page = 0
//                                postsViewModel.lastPage = true
//                                try await postsViewModel.fetchPosts()
//                            case .clubs:
//                                clubsVM.feedClubs = []
//                                clubsVM.page = 0
//                                clubsVM.lastPage = true
//                                try await clubsVM.fetchClubs()
//                            case .friends:
//                                print("friends")
//                            }
//
//                            done()
//                        }
//
//                    }
//                    .onChange(of: navManager.homeScrollTop) {
//                        if viewModel.showCancelButton {
//                            viewModel.showCancelButton = false
//                        } else {
//                            withAnimation {
//                                proxy.scrollTo("Top", anchor: .top)
//                            }
//                        }
//                    }
//                    .onChange(of: filterViewModel.selectedType) {
//                        switch filterViewModel.selectedType {
//                        case .events:
//                            print("here event")
//                            withAnimation {
//                                proxy.scrollTo("Top", anchor: .top)
//                            }
//                        case .clubs:
//                            withAnimation {
//                                proxy.scrollTo("Top", anchor: .top)
//                            }
//
//                            if clubsVM.feedClubs.count == 0 {
//                                Task{
//                                    clubsVM.page = 0
//                                    clubsVM.lastPage = true
//                                    try await clubsVM.fetchClubs()
//                                }
//                            }
//                        case .friends:
//                            withAnimation {
//                                proxy.scrollTo("Top", anchor: .top)
//                            }
//                            print("Change")
//                        }
//                    }
//
//                }
//                .overlay{
//                    if viewModel.showCancelButton {
//                        SearchView(viewModel: viewModel)
//                    }
//                }
//                .onChange(of: viewModel.showCancelButton){
//                    if viewModel.showCancelButton {
//                        viewModel.startSearch()
//                    } else {
//                        viewModel.stopSearch()
//                    }
//                }
//
//                CustomNavBar(showFilter: $showFilter, filterVM: filterViewModel, homeViewModel: viewModel)
//            }
//
//        }
//        .sheet(isPresented: $postsViewModel.showJoinRequest){
//            JoinRequestView(post: $postsViewModel.clickedPost, isActive: $postsViewModel.showJoinRequest, refreshParticipants: {})
//        }
//        .sheet(isPresented: $clubsVM.showJoinClubSheet){
//            JoinRequestClubView(club: $clubsVM.clickedClub, isActive: $clubsVM.showJoinClubSheet, refreshParticipants: {})
//        }
//        .sheet(isPresented: $filterViewModel.showAllFilter, content: {
//            AllInOneFilterView(filterVM: filterViewModel)
//        })
//
//
//    }
//
//}
