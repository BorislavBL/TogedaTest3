//
//  SearchView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct SearchView: View {
    @State private var users = User.MOCK_USERS
    @State private var searchText = ""
    @Environment(\.isSearching) var isSearching
    @State private var showDetailsPage = false
    @State var clickedPostIndex = 0
    
    @ObservedObject var postViewModel: PostsViewModel
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment: .leading, spacing: 10){
                
                Text("People")
                    .font(.title3)
                    .fontWeight(.bold)
                
                ForEach(users.indices, id: \.self) { i in
                    Button {
                    } label: {
                        HStack(alignment:.center, spacing: 10){
                            if let image = users[i].profileImageUrl{
                                Image(image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .cornerRadius(10)
                            }
                            VStack(alignment: .leading, spacing: 10) {
                                Text(users[i].fullname)
                                    .multilineTextAlignment(.leading)
                                    .font(.body)
                                    .fontWeight(.bold)
                                
                                if let title = users[i].title {
                                    Text(title)
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.gray)
                                        .fontWeight(.semibold)
                                        .font(.callout)
                                } else if let from = users[i].from {
                                    Text(from)
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
                    
                Text("Events")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.top, 30)
                
                ForEach(postViewModel.posts.indices, id: \.self) { i in
                    Button {
                        clickedPostIndex = i
                        showDetailsPage = true
                    } label: {
                        HStack(alignment:.center, spacing: 10){
                            Image(posts[i].imageUrl)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(10)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text(posts[i].title)
                                    .multilineTextAlignment(.leading)
                                    .font(.body)
                                    .fontWeight(.bold)
                                
                                if let fullname = posts[i].user?.fullname {
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
            }
            .padding(.all, 8)
            
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search...")
        .onChange(of: searchText) {
            
            if !searchText.isEmpty {
                self.postViewModel.posts = postViewModel.posts.filter { $0.title.lowercased().contains(searchText.lowercased()) }
                
                self.users = users.filter{$0.fullname.lowercased().contains(searchText.lowercased())}
            } else {
                self.postViewModel.posts = Post.MOCK_POSTS
                self.users = User.MOCK_USERS
            }
            
//            if !searchText.isEmpty {
//                self.posts = posts.filter { $0.title.lowercased().contains(searchText.lowercased()) }
//            } else {
//                self.posts = Post.MOCK_POSTS
//            }
        }
        .fullScreenCover(isPresented: $showDetailsPage) {
            EventView(viewModel: postViewModel, post: postViewModel.posts[clickedPostIndex], userViewModel: userViewModel)
        }
        .navigationTitle("Explore")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(postViewModel: PostsViewModel(), userViewModel: UserViewModel())
    }
}

