//
//  BookmarkedEventsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 12.01.24.
//

import SwiftUI

struct BookmarkedEventsView: View {
    var userID: String
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    @Environment(\.dismiss) var dismiss
    
    @State var lastPage: Bool = true
    @State var posts: [Components.Schemas.PostResponseDto] = []
    @State var page: Int32 = 0
    @State var size: Int32 = 15
    @State var isLoading = false
    
    var body: some View {
        ScrollView{
            LazyVStack{
                LazyVGrid(columns: columns){
                    ForEach(posts, id: \.id){ post in
                        if post.status == .HAS_ENDED {
                            NavigationLink(value: SelectionPath.completedEventDetails(post: post)){
                                EventComponent(userID: userID, post: post)
                            }
                        } else {
                            NavigationLink(value: SelectionPath.eventDetails(post)){
                                EventComponent(userID: userID, post: post)
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical)
                
                if isLoading {
                    ProgressView() // Show spinner while loading
                } else if lastPage {
                    VStack(spacing: 8){
                        Divider()
                        Text("No more posts")
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                    }
                    .padding()
                }
                
                Rectangle()
                    .frame(width: 0, height: 0)
                    .onAppear {
                        if !lastPage{
                            isLoading = true
                            Task{
                                try await fetchEvents()
                                isLoading = false
                                
                            }
                        }
                    }
            }
        }
        .refreshable {
            page = 0
            posts = []
            Task{
                try await fetchEvents()
            }
        }
        .scrollIndicators(.hidden)
        .swipeBack()
        .navigationTitle("Saved Events")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {dismiss()}) {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .background(.bar)
        .onAppear(){
            Task{
                try await fetchEvents()
            }
        }
    }
    
    func fetchEvents() async throws{
        if let response = try await APIClient.shared.getUserSavedEvents(page: page, size: size) {
            let newResponse = response.data
            let existingResponseIDs = Set(self.posts.suffix(30).map { $0.id })
            let uniqueNewResponse = newResponse.filter { !existingResponseIDs.contains($0.id) }
            
            posts += uniqueNewResponse
            lastPage = response.lastPage
            page += 1
            
        }
        
    }
    
}

#Preview {
    BookmarkedEventsView(userID: User.MOCK_USERS[0].id, posts: [MockPost])
}
