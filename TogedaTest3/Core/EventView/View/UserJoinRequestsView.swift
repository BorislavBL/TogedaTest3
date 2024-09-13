//
//  UserJoinRequestsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 30.05.24.
//

import SwiftUI

struct UserJoinRequestsView: View {
    private let size: ImageSize = .medium
    @Environment(\.dismiss) private var dismiss
    @StateObject var eventVM = EventViewModel()
    
    @State var isLoading = false
    
    var post: Components.Schemas.PostResponseDto

    var body: some View {
        ScrollView{
            LazyVStack(spacing: 16){
                ForEach(eventVM.joinRequestParticipantsList, id: \.miniUser.id) {user in
                    UserRequestComponent(user: user.miniUser, expiration: user.expiration, confirm: {
                        Task{
                            if try await APIClient.shared.acceptJoinRequest(postId: post.id, userId: user.miniUser.id, action:.ACCEPT) {
                                if let index = eventVM.joinRequestParticipantsList.firstIndex(where: { $0.miniUser.id == user.miniUser.id }) {
                                    eventVM.joinRequestParticipantsList.remove(at: index)
                                }
                            }
                        }
                        
                    }, delete: {
                        Task{
                            if try await APIClient.shared.acceptJoinRequest(postId: post.id, userId: user.miniUser.id, action:.DENY) {
                                if let index = eventVM.joinRequestParticipantsList.firstIndex(where: { $0.miniUser.id == user.miniUser.id }) {
                                    eventVM.joinRequestParticipantsList.remove(at: index)
                                }
                            }
                        }
                        
                    })
                }
                
                
                
                if isLoading{
                    ProgressView()
                }
                
                Rectangle()
                    .frame(width: 0, height: 0)
                    .onAppear {
                        if !eventVM.joinRequestLastPage {
                            isLoading = true
                            
                            Task{
                                try await eventVM.fetchJoinRequestUserList(id: post.id)
                                isLoading = false
                                
                            }
                        }
                    }
            }
        }
        .refreshable {
            eventVM.joinRequestParticipantsList = []
            eventVM.joinRequestParticipantsPage = 0
            Task{
                do{
                    try await eventVM.fetchJoinRequestUserList(id: post.id)
                } catch {
                    print("User list error:", error.localizedDescription)
                }
            }
        }
        .onAppear(){
            Task{
                do{
                    try await eventVM.fetchJoinRequestUserList(id: post.id)
                } catch {
                    print("User list error:", error.localizedDescription)
                }
            }
        }
        
        .navigationTitle("Event Join Requests")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
        .padding(.top)
        .padding(.horizontal)
        .swipeBack()
    }
}

#Preview {
    UserJoinRequestsView(post: MockPost)
}
