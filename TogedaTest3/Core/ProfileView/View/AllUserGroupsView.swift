//
//  AllUserGroupsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 2.01.24.
//

import SwiftUI

struct AllUserGroupsView: View {
    var userID: String
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    @Environment(\.dismiss) var dismiss
    
    @State var lastPage: Bool = true
    @State var clubs: [Components.Schemas.ClubDto] = []
    @State var page: Int32 = 0
    @State var size: Int32 = 15
    @State var isLoading = false
    
    @State var Init: Bool = true
    
    var body: some View {
        ScrollView{
            LazyVStack{
                LazyVGrid(columns: columns){
                    ForEach(clubs, id:\.id ){ club in
                        NavigationLink(value: SelectionPath.club(club)){
                            GroupComponent(userID: userID, club: club)
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
                        Text("No more clubs")
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
                                try await fetchClubs()
                                isLoading = false
                                
                            }
                        }
                    }
            }
        }
        .refreshable {
            clubs = []
            page = 0
            Task{
                try await fetchClubs()
            }
        }
        .onAppear(){
            if Init {
                clubs = []
                page = 0
                Task{
                    try await fetchClubs()
                    Init = false
                }
            }
        }
        .scrollIndicators(.hidden)
        .swipeBack()
        .navigationTitle("Clubs")
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
    }
    
    func fetchClubs() async throws{
        if let response = try await APIClient.shared.getUserClubs(userId: userID, page: page, size: size) {
            clubs += response.data
            lastPage = response.lastPage
            
            page += 1
        }
        
    }
    
}

#Preview {
    AllUserGroupsView(userID: "")
}
