//
//  SearchView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var postsViewModel: PostsViewModel
    @ObservedObject var userViewModel: UserViewModel
    let size: ImageSize = .medium
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment: .leading, spacing: 15){
                
                if viewModel.selectedFilter == "Events"{
                    ForEach(viewModel.searchPostResults, id:\.id){ post in
                        //                        Button {
                        //                            postsViewModel.showDetailsPage = true
                        //                            postsViewModel.clickedPostIndex = postsViewModel.posts.firstIndex(of: post) ?? 0
                        //                        } label: {
                        NavigationLink(value: postsViewModel.posts.firstIndex(of: post) ?? 0){
                            HStack(alignment:.center, spacing: 10){
                                Image(post.imageUrl[0])
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
                                    
                                    if let fullname = post.user?.fullname {
                                        Text(fullname)
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.gray)
                                            .fontWeight(.semibold)
                                            .font(.footnote)
                                    }
                                }
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .padding(.trailing, 10)
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        }
                    }
                } else if viewModel.selectedFilter == "People" {
                    ForEach(viewModel.searchUserResults, id: \.id) { user in
                        NavigationLink(value: user){
                            HStack(alignment:.center, spacing: 10){
                                Image(user.profileImageUrl[0])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size.dimension, height: size.dimension)
                                    .clipShape(Circle())
                                
                                Text(user.fullname)
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
            }
            .padding()
            .padding(.top, 94)
            
        }
        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
        .background()
    }
}


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(viewModel: HomeViewModel(), postsViewModel: PostsViewModel(), userViewModel: UserViewModel())
    }
}

