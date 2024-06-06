//
//  AllGroupEventsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 22.01.24.
//

import SwiftUI

struct AllGroupEventsView: View {
    var clubId: String
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
    @StateObject var vm = GroupViewModel()
    
    var body: some View {
        ScrollView{
            LazyVGrid(columns: columns){
                ForEach(posts, id: \.id){ post in
                    if post.status == .HAS_ENDED {
                        NavigationLink(value: SelectionPath.completedEventDetails(post: post)){
                            GroupEventComponent(post: post)
                        }
                    } else {
                        NavigationLink(value: SelectionPath.eventDetails(post)){
                            GroupEventComponent(post: post)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical)
            
            if isLoading {
                ProgressView() // Show spinner while loading
            } else {
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
                            try await vm.fetchClubMembers(clubId: clubId)
                            isLoading = false
                            
                        }
                    }
                }
        }
        .refreshable {
            vm.membersPage = 0
            vm.clubMembers = []
            Task{
                try await vm.fetchClubMembers(clubId: clubId)
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Events")
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
                try await vm.fetchClubMembers(clubId: clubId)
            }
        }
    }
    
}

#Preview {
    AllGroupEventsView(clubId: "")
}
