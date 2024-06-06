//
//  FriendsListView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.06.24.
//

import SwiftUI
import Kingfisher

struct FriendsListView: View {
    @Environment(\.dismiss) private var dismiss
    let size: ImageSize = .medium
    @EnvironmentObject var userVm: UserViewModel
    
    @State var isLoading = false
    
    var user: Components.Schemas.UserInfoDto
    @State var Init: Bool = true
    @State var friendsList: [Components.Schemas.MiniUser] = []
    @State var lastPage = true
    @State var page: Int32 = 0
    @State var pageSize: Int32 = 15
    
    @State var friendsRequestList: [Components.Schemas.MiniUser] = []
    @State var friendsRequestPage: Int32 = 0
    @State var friendsRequestSize: Int32 = 15

    
    var body: some View {
        ScrollView{
            LazyVStack(alignment:.leading){
                if let user = userVm.currentUser, user.id == user.id, friendsRequestList.count > 0{
                    NavigationLink(value: SelectionPath.userFriendRequestsList){
                        UserRequestTab(users: friendsRequestList)
                    }
                }
                ForEach(friendsList, id:\.id) { user in
                    HStack{
                        NavigationLink(value: SelectionPath.profile(user)){
                            HStack{
                                KFImage(URL(string: user.profilePhotos[0]))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size.dimension, height: size.dimension)
                                    .clipShape(Circle())
                                
                                Text("\(user.firstName) \(user.lastName)")
                                    .fontWeight(.semibold)
                                    
                                
                                Spacer()
                                
                                if let currentUser = userVm.currentUser, currentUser.id == self.user.id {
                                    Button{
                                        Task{
                                            if try await APIClient.shared.removeFriend(removeUserId: user.id) != nil {
                                                if let index = friendsRequestList.firstIndex(where: { $0.id == user.id }) {
                                                    friendsList.remove(at: index)
                                                }
                                            }
                                        }
                                    } label:{
                                        Text("Remove")
                                            .normalTagTextStyle()
                                            .normalTagCapsuleStyle()
                                    }
                                }
                            }
                            
                        }
                        
                        
                        
                    }
                    .padding(.vertical, 5)
                }
                
                if isLoading{
                    ProgressView()
                }
                
                Rectangle()
                    .frame(width: 0, height: 0)
                    .onAppear {
                        if !lastPage {
                            isLoading = true
                            
                            Task{
                                if let response = try await APIClient.shared.getFriendList(userId: user.id, page: page, size: pageSize){
                                    friendsList = response.data
                                    page += 1
                                    lastPage = response.lastPage
                                }
                                isLoading = false
                                
                            }
                        }
                    }
            }
            .padding(.horizontal)
            
        }
        .onAppear(){
            Task{
                do{
                    if Init {
                        if let response = try await APIClient.shared.getFriendList(userId: user.id, page: page, size: pageSize){
                            friendsList = response.data
                            page += 1
                            lastPage = response.lastPage
                        }
                        Init = false
                    }
                        friendsRequestList = []
                        friendsRequestPage = 0
                    if let response = try await APIClient.shared.getFriendRequests(page: friendsRequestPage, size: friendsRequestSize){
                        friendsRequestList = response.data
                    }
                    
                } catch {
                    print("User list error:", error.localizedDescription)
                }
            }
        }
        .navigationTitle("Friends")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
    }
}

#Preview {
    FriendsListView(user: MockUser)
        .environmentObject(UserViewModel())
}
