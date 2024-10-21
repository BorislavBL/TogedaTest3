//
//  FriendsFeedView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 9.07.24.
//

import SwiftUI

struct FriendsFeedView: View {
    @State var isLoading: Bool = false
    @State private var previousMinY: CGFloat = 0
    @Binding var showFilter: Bool
    @ObservedObject var filterViewModel: FilterViewModel
    @EnvironmentObject var navManager: NavigationManager
    @EnvironmentObject var activityVM: ActivityViewModel
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false){
                LazyVStack (spacing: 10){
                    Color.clear
                        .frame(height: 74)
                        .id("Top")
                    if activityVM.state == .loaded  {
                        
                        ForEach(Array(activityVM.activityFeed.enumerated()), id: \.element.id) {index, activity in
                            if let post = activity.post {
                                ActivityPostCell(post: post, activity: activity)
                            } else if let club = activity.club {
                                ClubCellActivity(club: club, activity: activity)
                            }
                        }
                        
                        if isLoading {
                            PostSkeleton() // Show spinner while loading
                        } else if activityVM.lastPage && activityVM.activityFeed.count > 0 {
                            VStack(spacing: 8){
                                Divider()
                                Text("No more posts")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.gray)
                                
                            }
                            .padding()
                        }
                        
                    } else if activityVM.state == .loading {
                        ForEach(0..<5, id: \.self) { index in
                            PostSkeleton()
                        }
                    } else if activityVM.state == .noResults{
                        VStack(spacing: 15){
//                            Image(systemName: "doc.text.magnifyingglass")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 120, height: 120)
//                                .foregroundStyle(.gray)
                            
                            Text("🥳")
                                .font(.custom("image", fixedSize: 120))
                            
                            Text("It seems your friends are a bit quiet right now. \n Why not shake things up? \n Create something fun and invite them to join!")
                                .font(.body)
                                .foregroundStyle(.gray)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .padding(.bottom)
                            
                            Button {
                                navManager.isPresentingEvent = true
                            } label: {
                                Text("Create Event")
                                    .font(.subheadline)
                                    .foregroundStyle(Color("base"))
                                    .fontWeight(.semibold)
                                    .frame(minWidth: 0, maxWidth: 200, alignment: .center)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 13)
                                    .background{Color("blackAndWhite")}
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.all)
                        .frame(maxHeight: .infinity, alignment: .center)
                    } else if activityVM.state == .refresh {
                        VStack(spacing: 15){
//                            Image(systemName: "doc.text.magnifyingglass")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 120, height: 120)
//                                .foregroundStyle(.gray)
                            
                            Text("👀")
                                .font(.custom("image", fixedSize: 120))
                            
                            Text("Oops! There seems to be a problem with your internet connection, and the content couldn’t load.\n Please check your connection and click 'Refresh' to try again.")
                                .font(.body)
                                .foregroundStyle(.gray)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .padding(.bottom)
                            
                            Button {
                                Task{
                                    try await refresh()
                                }
                            } label: {
                                Text("Refresh")
                                    .font(.subheadline)
                                    .foregroundStyle(Color("base"))
                                    .fontWeight(.semibold)
                                    .frame(minWidth: 0, maxWidth: 200, alignment: .center)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 13)
                                    .background{Color("blackAndWhite")}
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.all)
                        .frame(maxHeight: .infinity, alignment: .center)
                    }
                    
                    Rectangle()
                        .frame(width: 0, height: 0)
                        .onAppear {
                            if !activityVM.lastPage {
                                isLoading = true
                                Task{
                                    try await activityVM.fetchFeed()
                                    isLoading = false
                                    
                                }
                            }
                            
                            
                        }
                    
                }
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
                    try await refresh()
                    done()
                }
                
            }
            .onChange(of: navManager.homeScrollTop) {
                if viewModel.showCancelButton {
                    viewModel.showCancelButton = false
                } else {
                    if filterViewModel.selectedType == .friends{
                        withAnimation {
                            proxy.scrollTo("Top", anchor: .top)
                        }
                    }
                }
            }
        }
    }
    
    func refresh() async throws{
        activityVM.state = .loading
        activityVM.activityFeed = []
        activityVM.page = 0
        activityVM.lastPage = true
        try await activityVM.fetchFeed()
    }
}

#Preview {
    FriendsFeedView(showFilter: .constant(false), filterViewModel: FilterViewModel(), viewModel: HomeViewModel())
        .environmentObject(LocationManager())
        .environmentObject(ActivityViewModel())
        .environmentObject(PostsViewModel())
        .environmentObject(ClubsViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(NavigationManager())
}
