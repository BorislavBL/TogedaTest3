//
//  Test2View.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.11.23.
//

import SwiftUI
import Kingfisher

struct Test2View: View {
    @EnvironmentObject var postsViewModel: PostsViewModel
    @State var isLoading: Bool = false
    @State private var previousMinY: CGFloat = 0
    @Binding var showFilter: Bool
    @ObservedObject var filterViewModel: FilterViewModel
    @EnvironmentObject var navManager: NavigationManager
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        List {
            ForEach(Array(postsViewModel.feedPosts.enumerated()), id: \.element.id) { index, post in
//                PostCell(post: post)
//                    .id(post.id)
//                    .onAppear(){
//                        postsViewModel.feedScrollFetch(index: index)
//                    }
                    KFImage.url(URL(string: post.images[0])!)
                        .resizable()
                        .scaledToFill()
                        .frame(maxHeight: 400)
                        .cornerRadius(10)
                        .background(
                            NavigationLink(value: SelectionPath.eventDetails(post)) {
                                Rectangle()
                                    .frame(height: 400)
                            }
                        )
                        .listRowSeparator(.hidden)
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
        .scrollIndicators(.hidden)
        .listStyle(.plain)
        .refreshable {
            Task{
                try await refresh()
                
            }
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
    Test2View(showFilter: .constant(false), filterViewModel: FilterViewModel(), viewModel: HomeViewModel())
        .environmentObject(LocationManager())
        .environmentObject(PostsViewModel())
        .environmentObject(ClubsViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(NavigationManager())
}

