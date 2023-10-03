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
    @State private var height: CGFloat = 94
    let navbarHeight: CGFloat = 94
    
    @StateObject var filterViewModel = FilterViewModel()
//    @StateObject var postsViewModel = PostsViewModel()
//    @StateObject var userViewModel = UserViewModel()
    @ObservedObject var postsViewModel: PostsViewModel
    @ObservedObject var userViewModel: UserViewModel
    @State var test = false
    
    @State private var refreshingHeight:CGFloat = 0.0
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color("testColor")
                    .edgesIgnoringSafeArea(.vertical)
                
                ZStack(alignment: .top) {
                    
                    VStack {
                        Color.clear
                            .frame(height: refreshingHeight)
                        
                        ScrollView(.vertical, showsIndicators: false){
                            LazyVStack (spacing: 10){
                                ForEach(postsViewModel.posts, id: \.id) { post in
                                    PostCell(viewModel: postsViewModel, post: post, userViewModel: userViewModel)
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
                            postsViewModel.fetchPosts()
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
                    
                    
                    CustomNavBar(showFilter: $showFilter, viewModel: filterViewModel, postViewModel: postsViewModel, userViewModel: userViewModel)
                        .anchorPreference(key:HeaderBoundsKey.self, value:.bounds) {$0}
                        .overlayPreferenceValue(HeaderBoundsKey.self) { value in
                            GeometryReader{proxy in
                                if let anchor = value {
                                    Color.clear
                                        .onAppear{
                                            height = proxy[anchor].height
                                        }
                                }
                            }
                        }
                }
                
            }
            .sheet(isPresented: $filterViewModel.filterIsSelected) {
                if let options = filterViewModel.selectedFilter?.options{
                    VStack(spacing: 20){
                        
                        List{
                            Section{
                                ForEach(options) { option in
                                    Button {
                                        print(option.name)
                                        filterViewModel.filters[filterViewModel.selectedFilterIndex].selectingCategory = option.name
                                    } label: {
                                        HStack{
                                            Text(option.name)
                                            
                                            Spacer()
                                            
                                            if(option.name == filterViewModel.filters[filterViewModel.selectedFilterIndex].selectingCategory){
                                                Image(systemName: "checkmark")
                                            }
                                            
                                        }
                                        
                                    }                                }
                                
                            } footer: {
                                Button {
                                    print("Done")
                                    filterViewModel.filters[filterViewModel.selectedFilterIndex].selectedCategory = filterViewModel.filters[filterViewModel.selectedFilterIndex].selectingCategory
                                    filterViewModel.filterIsSelected = false
                                } label: {
                                    Text("Submit")
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 60)
                                        .background(Color("blackAndWhite"))
                                        .foregroundColor(Color("testColor"))
                                        .fontWeight(.semibold)
                                    
                                }
                                .cornerRadius(10)
                                .padding(.top)
                            }
                            
                        }
                        
                    }
                    .presentationDetents([.fraction(0.9)])
                    .presentationDragIndicator(.visible)
                    .background(Color(UIColor.systemGroupedBackground))
                }
            }
//            .sheet(isPresented: $postsViewModel.showPostOptions, content: {
//                List {
//                    Button("Save") {
//                        postsViewModel.selectedOption = "Save"
//                    }
//                    
//                    Button("Share via") {
//                        postsViewModel.selectedOption = "Share"
//                    }
//                    
//                    Button("Report") {
//                        postsViewModel.selectedOption = "Report"
//                    }
//                }
//                .presentationDetents([.fraction(0.4)])
//                .presentationDragIndicator(.visible)
//            })
//            .fullScreenCover(isPresented: $postsViewModel.showDetailsPage, content: {
//                EventView(viewModel: postsViewModel, post: postsViewModel.posts[postsViewModel.clickedPostIndex], userViewModel: userViewModel)
//            })
            .navigationDestination(for: Post.self) { post in
                EventView(viewModel: postsViewModel, post: post, userViewModel: userViewModel)
                //.toolbar(.hidden, for: .tabBar)
            }
            .navigationDestination(for: User.self) { user in
                Text(user.username)
            }
        }
        
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(postsViewModel: PostsViewModel(), userViewModel: UserViewModel())
    }
}


