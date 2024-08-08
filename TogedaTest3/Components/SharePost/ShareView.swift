//
//  SharePostView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 4.12.23.
//

import SwiftUI
import WrappingHStack
import Kingfisher

struct ShareView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userVM: UserViewModel
    @State var searchText: String = ""
    let size: ImageSize = .small
    @State var searchUserResults: [Components.Schemas.GetFriendsDto] = []
    @State var selectedUsers: [Components.Schemas.GetFriendsDto] = []
    @State var showCancelButton: Bool = false
    var post: Components.Schemas.PostResponseDto?
    var club: Components.Schemas.ClubDto?
    
    @State var friendsList: [Components.Schemas.GetFriendsDto] = []
    @State var lastPage: Bool = true
    @State var page: Int32 = 0
    @State var listSize: Int32 = 15
    @State var isLoading = false
    
    let testLink = URL(string: "https://www.linkedin.com/in/borislav-lorinkov-724300232/")!
    
    var body: some View {
        VStack {
            HStack(spacing: 16){
                CustomSearchBar(searchText: $searchText, showCancelButton: $showCancelButton)
                    
                
                if !showCancelButton {
                    ShareLink("", item: testLink)
                }
            }
            .padding()
            
            ScrollView {
                if selectedUsers.count > 0{
                    ScrollView{
                        WrappingHStack(alignment: .topLeading){
                            ForEach(selectedUsers, id: \.user.id) { user in
                                ParticipantsChatTags(user: user){
                                    selectedUsers.removeAll(where: { $0 == user })
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxHeight: 100)
                }
                
                LazyVStack {
                    ForEach(friendsList, id: \.user.id) { user in
                        VStack {
                            Button{
                                if selectedUsers.contains(user) {
                                    selectedUsers.removeAll(where: { $0 == user })
                                } else {
                                    selectedUsers.append(user)
                                }
                            } label:{
                                HStack {
                                    if selectedUsers.contains(user){
                                        Image(systemName: "checkmark.circle.fill")
                                            .imageScale(.large)
                                            .foregroundStyle(.blue)
                                    } else {
                                        Image(systemName: "circle")
                                            .imageScale(.large)
                                            .foregroundStyle(.gray)
                                    }
                                    
                                    KFImage(URL(string: user.user.profilePhotos[0]))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: size.dimension, height: size.dimension)
                                        .clipShape(Circle())
                                    
                                    Text("\(user.user.firstName) \(user.user.lastName)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                }
                            }
                            
                            Divider()
                                .padding(.leading, 40)
                        }
                        .padding(.leading)
                    }
                    
                    Rectangle()
                        .frame(width: 0, height: 0)
                        .onAppear {
                            if !lastPage{
                                isLoading = true
                                Task{
                                    try await fetchList()
                                    isLoading = false
                                    
                                }
                            }
                            
                        }
                }
            }
            .onChange(of: searchText){
//                if !searchText.isEmpty {
//                    searchUserResults = MiniUser.MOCK_MINIUSERS.filter{result in
//                        result.fullName.lowercased().contains(searchText.lowercased())
//                    }
//                } else {
//                    searchUserResults = MiniUser.MOCK_MINIUSERS
//                }
            }
            
            if selectedUsers.count > 0 {
                VStack{
                    Button{
                        Task{
                            if let post = post {
                                let chatRoomsIDs: Components.Schemas.ChatRoomIdsDto = Components.Schemas.ChatRoomIdsDto.init(chatRoomIds: selectedUsers.map { friends in
                                    return friends.chatRoomId
                                })
                                if let response = try await APIClient.shared.shareEvent(postId: post.id, chatRoomIds: chatRoomsIDs) {
                                    print("\(response)")
                                    dismiss()
                                }
                            }
                            
                            else if let club = club {
                                let chatRoomsIDs: Components.Schemas.ChatRoomIdsDto = Components.Schemas.ChatRoomIdsDto.init(chatRoomIds: selectedUsers.map { friends in
                                    return friends.chatRoomId
                                })
                                if let response = try await APIClient.shared.shareClub(clubId: club.id, chatRoomIds: chatRoomsIDs) {
                                    print("\(response)")
                                    dismiss()
                                }
                            }
                        }
                    } label: {
                        Text("Send")
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .fontWeight(.semibold)
                        
                    }
                    .cornerRadius(10)
                    .padding(.top)
                }
                .padding(.horizontal)
            }
            

        }
        .onAppear(){
            Task{
                try await fetchList()
            }
        }
    }
    
    func fetchList() async throws {
        if let currentUser = userVM.currentUser {
            if let response = try await APIClient.shared.getFriendList(userId: currentUser.id, page: page, size: listSize) {
                friendsList = response.data
                page += 1
                lastPage = response.lastPage
            }
        }
    }
}

#Preview {
    ShareView()
        .environmentObject(UserViewModel())
}
