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
                
                if !lastPage{
                    if isLoading {
                        ProgressView()
                    } else {
                        Button{
                            isLoading = true
                            Task{
                                try await fetchClubs()
                                isLoading = false
                                
                            }
                        } label: {
                            Text("Load More")
                                .selectedTagTextStyle()
                                .selectedTagRectangleStyle()
                        }
                    }
                } else if lastPage && clubs.count > 0 {
                    VStack(spacing: 8){
                        Divider()
                        Text("No more clubs")
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                    }
                    .padding()
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
            let newResponse = response.data
            let existingResponseIDs = Set(self.clubs.suffix(30).map { $0.id })
            let uniqueNewResponse = newResponse.filter { !existingResponseIDs.contains($0.id) }
            
            clubs += uniqueNewResponse
            lastPage = response.lastPage
            
            page += 1
        }
        
    }
    
}

#Preview {
    AllUserGroupsView(userID: "")
}
