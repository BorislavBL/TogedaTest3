//
//  SearchView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import Kingfisher

struct SearchView: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    let size: ImageSize = .medium
    
    @State var isLoading = false
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment: .leading, spacing: 15){
                if viewModel.selectedFilter == .events{
                    ForEach(viewModel.searchedPosts, id:\.id){ post in
                        NavigationLink(value: SelectionPath.eventDetails(post)){
                            HStack(alignment:.center, spacing: 10){
                                KFImage(URL(string: post.images[0]))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size.dimension, height: size.dimension)
                                    .clipped()
                                    .cornerRadius(10)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(post.title)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                    
                                    Text("\(post.owner.firstName) \(post.owner.lastName)")
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.gray)
                                        .fontWeight(.semibold)
                                        .font(.footnote)
                                    
                                }
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .padding(.trailing, 10)
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        }
                    }
                } else if viewModel.selectedFilter == .users {
                    ForEach(viewModel.searchedUsers, id: \.id) { user in
                        NavigationLink(value: SelectionPath.profile(user)){
                            HStack(alignment:.center, spacing: 10){
                                KFImage(URL(string: user.profilePhotos[0]))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size.dimension, height: size.dimension)
                                    .clipShape(Circle())
                                
                                Text("\(user.firstName) \(user.lastName)")
                                    .multilineTextAlignment(.leading)
                                    .fontWeight(.semibold)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .padding(.trailing, 10)
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        }
                    }
                } else if viewModel.selectedFilter == .clubs {
                    ForEach(viewModel.searchedClubs, id: \.id) { club in
                        NavigationLink(value: SelectionPath.club(club)){
                            HStack(alignment:.center, spacing: 10){
                                KFImage(URL(string: club.images[0]))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size.dimension, height: size.dimension)
                                    .clipShape(Circle())
                                
                                Text("\(club.title)")
                                    .multilineTextAlignment(.leading)
                                    .fontWeight(.semibold)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .padding(.trailing, 10)
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                
                if isLoading {
                    ProgressView() // Show spinner while loading
                }
                
                Rectangle()
                    .frame(width: 0, height: 0)
                    .onAppear {
                        if !viewModel.lastSearchedPage{
                           isLoading = true
                            Task{
                                if viewModel.selectedFilter == .events {
                                    Task{
                                        try await viewModel.searchPosts()
                                    }
                                } else if viewModel.selectedFilter == .users {
                                    Task{
                                        try await viewModel.searchUsers()
                                    }
                                } else if viewModel.selectedFilter == .clubs {
                                    Task{
                                        try await viewModel.searchClubs()
                                    }
                                }
                                isLoading = false
       
                            }
                        }
                    }
            }
            .padding()
            .padding(.top, 94)
            
        }
        .toolbar{
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardToolbarItems()
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
        .background(.bar)
        .ignoresSafeArea(.keyboard)
    }
}


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(viewModel: HomeViewModel())
            .environmentObject(UserViewModel())
    }
}

