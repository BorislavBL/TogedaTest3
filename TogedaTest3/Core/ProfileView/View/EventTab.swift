//
//  EventTab.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct EventTab: View {
    
    @State var selectedFilter: String = "All"
    
    private let gridItems: [GridItem] = [
        .init(.flexible(), spacing: 2),
        .init(.flexible(), spacing: 2),
        .init(.flexible(), spacing: 2),
    ]
    @Binding var selectedPost: Post
    @Binding var showCompletedView: Bool
    @State var posts: [Post] = Post.MOCK_POSTS
    
    var body: some View {
        VStack (alignment: .leading, spacing: 20) {
            Text("Events")
                .font(.body)
                .fontWeight(.bold)
            
            HStack(alignment: .center, spacing: 5) {
                
                ForEach(["All", "Participated", "Created"], id:\.self) {filter in
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
                        showCompletedView = true
                    }label:{
                        EventComponent(post: posts[index])
                    }
                }
            }
            
            NavigationLink(destination: UserTabViews(title: "Events", filters: ["All", "Participated", "Created"])) {
                Text("View All")
                    .normalTagTextStyle()
                    .frame(maxWidth: .infinity)
                    .normalTagRectangleStyle()
                    
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding()
        .background(.bar)
        .cornerRadius(10)
    }
}



struct EventTab_Previews: PreviewProvider {
    static var previews: some View {
        EventTab(selectedPost: .constant(Post.MOCK_POSTS[0]), showCompletedView: .constant(true))

    }
}
