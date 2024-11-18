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
    @State var friendsList: [Components.Schemas.GetFriendsDto] = []
    @State var lastPage = true
    @State var page: Int32 = 0
    @State var pageSize: Int32 = 15
    
    @State var friendsRequestList: [Components.Schemas.MiniUser] = []
    @State var friendsRequestPage: Int32 = 0
    @State var friendsRequestSize: Int32 = 15
    @State var loadingState: LoadingCases = .loading

    var isCurrentUser: Bool {
        if let user = userVm.currentUser, user.id == user.id {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment:.leading){
                if let user = userVm.currentUser, user.id == user.id, friendsRequestList.count > 0 {
                    NavigationLink(value: SelectionPath.userFriendRequestsList){
                        UserRequestTab(users: friendsRequestList)
                    }
                }
                if friendsList.count > 0 {
                    ForEach(friendsList, id:\.user.id) { userData in
                        HStack{
                            NavigationLink(value: SelectionPath.profile(userData.user)){
                                HStack{
                                    KFImage(URL(string: userData.user.profilePhotos[0]))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: size.dimension, height: size.dimension)
                                        .clipShape(Circle())
                                    
                                    Text("\(userData.user.firstName) \(userData.user.lastName)")
                                        .fontWeight(.semibold)
                                    
                                    
                                    Spacer()
                                    
                                    if let currentUser = userVm.currentUser, currentUser.id == self.user.id {
                                        Button{
                                            Task{
                                                if try await APIClient.shared.removeFriend(removeUserId: userData.user.id) != nil {
                                                    if let index = friendsList.firstIndex(where: { $0.user.id == userData.user.id }) {
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
                                        let newResponse = response.data
                                        let existingResponseIDs = Set(self.friendsList.suffix(30).map { $0.user.id })
                                        let uniqueNewResponse = newResponse.filter { !existingResponseIDs.contains($0.user.id) }
                                        
                                        friendsList += uniqueNewResponse
                                        page += 1
                                        lastPage = response.lastPage
                                    }
                                    isLoading = false
                                    
                                }
                            }
                        }
                } else if loadingState == .noResults {
                    VStack(spacing: 15){
                        Text("🤝")
                            .font(.custom("image", fixedSize: 120))
                        
                        Text("Every great journey starts with a single connection! Join clubs, attend events, and send friend requests to start building your circle. New friendships await!")
                            .font(.body)
                            .foregroundStyle(.gray)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding(.bottom)
                        
                    }
                    .padding(.all)
                    .frame(maxHeight: .infinity, alignment: .center)
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
                            loadingState = .loaded
                            Init = false
                            
                            if response.lastPage && friendsList.count == 0{
                                loadingState = .noResults
                            }
                        } else {
                            loadingState = .noResults
                            Init = false
                        }
                        
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
        .swipeBack()
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
