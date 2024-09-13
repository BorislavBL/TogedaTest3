//
//  AllGroupEventsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 22.01.24.
//

import SwiftUI

struct AllClubEventsView: View {
    var clubId: String
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    @Environment(\.dismiss) var dismiss
    @State var isLoading = false
    @StateObject var vm = ClubViewModel()
    @State var Init = true
    
    var body: some View {
        ScrollView{
            VStack{
                LazyVGrid(columns: columns){
                    ForEach(vm.clubEvents, id: \.id){ post in
//                        if post.status == .HAS_ENDED {
//                            NavigationLink(value: SelectionPath.completedEventDetails(post: post)){
//                                ClubEventComponent(post: post)
//                            }
//                        } else {
                            NavigationLink(value: SelectionPath.eventDetails(post)){
                                ClubEventComponent(post: post)
                            }
//                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical)
                
                if !vm.clubEventsLastPage{
                    if isLoading {
                        ProgressView()
                    } else {
                        Button{
                            isLoading = true
                            Task{
                                try await vm.fetchClubEvents(clubId: clubId)
                                isLoading = false
                                
                            }
                        } label: {
                            Text("Load More")
                                .selectedTagTextStyle()
                                .selectedTagRectangleStyle()
                        }
                    }
                } else if vm.clubEventsLastPage && vm.clubEvents.count > 0 {
                    VStack(spacing: 8){
                        Divider()
                        Text("No more posts")
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                    }
                    .padding()
                }
            }
        }
        .refreshable {
            vm.clubEvents = []
            vm.clubEventsPage = 0
            Task{
                try await vm.fetchClubEvents(clubId: clubId)
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
                if Init {
                    vm.clubEvents = []
                    vm.clubEventsPage = 0
                    try await vm.fetchClubEvents(clubId: clubId)
                    Init = false
                }
            }
        }
        .swipeBack()
    }
    
}

#Preview {
    AllClubEventsView(clubId: "")
}
