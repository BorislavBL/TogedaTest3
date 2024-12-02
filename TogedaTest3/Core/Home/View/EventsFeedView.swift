//
//  EventsFeedView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.07.24.
//

import SwiftUI

struct EventsFeedView: View {
    @EnvironmentObject var postsViewModel: PostsViewModel
    @State var isLoading: Bool = false
    @State private var previousMinY: CGFloat = 0
    @Binding var showFilter: Bool
    @ObservedObject var filterViewModel: FilterViewModel
    @EnvironmentObject var navManager: NavigationManager
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false){
                LazyVStack (spacing: 10){
                    Color.clear
                        .frame(height: 74)
                        .id("Top")
                    
                    if filterViewModel.updateEvents {
                        updateLocationButton()
                    }
                    
                    if postsViewModel.state == .loaded {
                        ForEach(Array(postsViewModel.feedPosts.enumerated()), id: \.element.id) {index, post in
                            PostCell(post: post)
                                .id(post.id)
                                .onAppear(){
                                    postsViewModel.feedScrollFetch(index: index)
                                }
                        }
                        
                        if isLoading {
                            PostSkeleton() // Show spinner while loading
                        } else if postsViewModel.lastPage && postsViewModel.feedPosts.count > 0 {
                            VStack(spacing: 8){
                                Divider()
                                Text("No more posts")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.gray)
                                
                            }
                            .padding()
                        }
                        
                    } else if postsViewModel.state == .loading {
                        ForEach(0..<5, id: \.self) { index in
                            PostSkeleton()
                        }
                    } else if postsViewModel.state == .noResults{
                        VStack(spacing: 15){
                            Text("😎")
                                .font(.custom("image", fixedSize: 120))
                            
                            Text("No events currently in this area. \n Create one yourself!")
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
                    } else if postsViewModel.state == .refresh {
                        VStack(spacing: 15){
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
                            if !postsViewModel.lastPage{
                                isLoading = true
                                Task{
                                    try await postsViewModel.fetchPosts()
                                    isLoading = false
                                    
                                }
                            }
                            
                        }
                }
                //                        .padding(.top, navbarHeight - 20)
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
                                        
                }
                done()
            }
            .onChange(of: navManager.homeScrollTop) {
                if viewModel.showCancelButton {
                    viewModel.showCancelButton = false
                } else {
                    if filterViewModel.selectedType == .events{
                        withAnimation {
                            proxy.scrollTo("Top", anchor: .top)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func updateLocationButton() -> some View {
        Button{
            Task{
                await withCheckedContinuation { continuation in
                    DispatchQueue.main.async{
                        postsViewModel.long = filterViewModel.returnedPlace.longitude
                        postsViewModel.lat = filterViewModel.returnedPlace.latitude
                        continuation.resume()
                    }
                }
                try await refresh()
                
                filterViewModel.updateEvents = false
            }
        } label:{
            Text("Update Location")
                .foregroundColor(Color("selectedTextColor"))
                .font(.footnote)
                .fontWeight(.bold)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background{Capsule().fill(Color("SelectedFilter"))}
        }
    }
    
    func refresh() async throws{
        postsViewModel.state = .loading
        postsViewModel.feedPosts = []
        postsViewModel.page = 0
        postsViewModel.lastPage = true
        try await postsViewModel.fetchPosts()
    }
}

#Preview {
    EventsFeedView(showFilter: .constant(false), filterViewModel: FilterViewModel(), viewModel: HomeViewModel())
        .environmentObject(LocationManager())
        .environmentObject(PostsViewModel())
        .environmentObject(ClubsViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(NavigationManager())
}
