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
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment: .leading, spacing: 10){
                
                if viewModel.selectedFilter == "Events"{
                    ForEach(viewModel.searchPostResults, id:\.id){ post in
                        Button {
                            postsViewModel.showDetailsPage = true
                            postsViewModel.clickedPostIndex = postsViewModel.posts.firstIndex(of: post) ?? 0
                        } label: {
                            HStack(alignment:.center, spacing: 10){
                                Image(post.imageUrl[0])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .cornerRadius(10)
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(post.title)
                                        .multilineTextAlignment(.leading)
                                        .font(.body)
                                        .fontWeight(.bold)
                                    
                                    if let fullname = post.user?.fullname {
                                        Text(fullname)
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.gray)
                                            .fontWeight(.semibold)
                                            .font(.callout)
                                    }
                                }
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .padding(.trailing, 10)
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .normalTagRectangleStyle()
                        }
                    }
                } else if viewModel.selectedFilter == "People" {
                    ForEach(viewModel.searchUserResults, id: \.id) { user in
                        Button {

                        } label: {
                            HStack(alignment:.center, spacing: 10){
                                if let image = user.profileImageUrl {
                                    Image(image[0 ])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipped()
                                        .cornerRadius(10)
                                }
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(user.fullname)
                                        .multilineTextAlignment(.leading)
                                        .font(.body)
                                        .fontWeight(.bold)
                                    
                                }
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .padding(.trailing, 10)
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .normalTagRectangleStyle()
                        }
                    }
                }
            }
            .padding()
            
        }
        .padding(.top, 94)
        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
        .background()
    }
}


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(viewModel: HomeViewModel(), postsViewModel: PostsViewModel(), userViewModel: UserViewModel())
    }
}

