//
//  FriendsRequestsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.06.24.
//

import SwiftUI

struct FriendsRequestsView: View {
    private let size: ImageSize = .medium
    @Environment(\.dismiss) private var dismiss
    
    @State var isLoading = false
    
    @State var friendsRequestList: [Components.Schemas.MiniUser] = []
    @State var friendsRequestPage: Int32 = 0
    @State var friendsRequestSize: Int32 = 15
    @State var Init: Bool = true
    @State var lastPage = true
    
    var body: some View {
        ScrollView{
            LazyVStack(spacing: 16){
                ForEach(friendsRequestList, id: \.id) {user in
                    UserRequestComponent(user: user, confirm: {
                        Task{
                            if try await APIClient.shared.respondToFriendRequest(toUserId: user.id, action: .ACCEPT) != nil{
                                if let index = friendsRequestList.firstIndex(where: { $0.id == user.id }) {
                                    friendsRequestList.remove(at: index)
                                }
                            }
                        }
                        
                    }, delete: {
                        Task{
                            if try await APIClient.shared.respondToFriendRequest(toUserId: user.id, action: .DENY) != nil{
                                if let index = friendsRequestList.firstIndex(where: { $0.id == user.id }) {
                                    friendsRequestList.remove(at: index)
                                }
                            }
                        }
                        
                    })
                }
                
                ListLoadingButton(isLoading: $isLoading, isLastPage: lastPage) {
                    Task{
                        defer{isLoading = false}
                        if let response = try await APIClient.shared.getFriendRequests(page: friendsRequestPage, size: friendsRequestSize){
                            let newResponse = response.data
                            let existingResponseIDs = Set(self.friendsRequestList.suffix(30).map { $0.id })
                            let uniqueNewResponse = newResponse.filter { !existingResponseIDs.contains($0.id) }
                            
                            friendsRequestList += uniqueNewResponse
                            friendsRequestPage += 1
                            lastPage = response.lastPage
                        }
                    }
                }

            }
        }
        .refreshable {
            friendsRequestList = []
            friendsRequestPage = 0
            Task{
                do{
                    if let response = try await APIClient.shared.getFriendRequests(page: friendsRequestPage, size: friendsRequestSize){
                        friendsRequestList = response.data
                        friendsRequestPage += 1
                        lastPage = response.lastPage
                    }
                } catch {
                    print("User list error:", error.localizedDescription)
                }
            }
        }
        .onAppear(){
            Task{
                do{
                    if Init {
                        if let response = try await APIClient.shared.getFriendRequests(page: friendsRequestPage, size: friendsRequestSize){
                            friendsRequestList = response.data
                            friendsRequestPage += 1
                            lastPage = response.lastPage
                        }
                        Init = false
                    }
                } catch {
                    print("User list error:", error.localizedDescription)
                }
            }
        }
        .swipeBack()
        .navigationTitle("Friend Requests")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
        .padding(.top)
        .padding(.horizontal)
        
    }
}

#Preview {
    FriendsRequestsView()
}
