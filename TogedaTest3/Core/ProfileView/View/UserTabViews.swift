//
//  UserTabViews.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.10.23.
//

import SwiftUI

struct UserTabViews: View {
    
    let title: String
    let filters: [String]
    
    @State var selectedFilter: String = "All"
    @Environment(\.dismiss) private var dismiss
    private let gridItems: [GridItem] = [
        .init(.flexible(), spacing: 2),
        .init(.flexible(), spacing: 2),
        .init(.flexible(), spacing: 2),
    ]
    
    @State var selectedPost: Post = Post.MOCK_POSTS[0]
    @State var showCompletedEvent: Bool = false
    @State var posts: [Post] = Post.MOCK_POSTS
    var body: some View {
        
        ScrollView{
            VStack (alignment: .leading, spacing: 20) {
                
                HStack(alignment: .center, spacing: 5) {
                    
                    ForEach(filters, id:\.self) {filter in
                        Button {
                            selectedFilter = filter
                        } label: {
                            if selectedFilter == filter {
                                Text(filter)
                                    .selectedTagTextStyle()
                                    .selectedTagCapsuleStyle()
                            } else {
                                Text(filter)
                                    .normalTagTextStyle()
                                    .normalTagCapsuleStyle()
                            }
                        }
                    }
                    
                }
                
                
                LazyVGrid(columns: gridItems, spacing: 10) {
                    ForEach(0..<6, id: \.self){ index in
                        Button{
                            selectedPost = posts[index]
                            showCompletedEvent = true
                        }label:{
                            EventComponent(post: posts[index])
                        }
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            .padding()

            
        }
        .background(.bar)
        .navigationBarBackButtonHidden(true)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .imageScale(.medium)
                .padding(.all, 8)
                .background(Color("secondaryColor"))
                .clipShape(Circle())
        }
        )
        .fullScreenCover(isPresented: $showCompletedEvent, content: {
            CompletedEventView(viewModel: PostsViewModel(), post: selectedPost, userViewModel: UserViewModel())
        })
        
    }
}

#Preview {
    UserTabViews(title: "Events", filters: ["All", "Current", "Past"])
}
