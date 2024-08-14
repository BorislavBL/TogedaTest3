//
//  GroupJoinRequestsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 31.05.24.
//

import SwiftUI

struct ClubJoinRequestsView: View {
    private let size: ImageSize = .medium
    @Environment(\.dismiss) private var dismiss
    @StateObject var groupVM = ClubViewModel()
    
    @State var isLoading = false
    
    var club: Components.Schemas.ClubDto

    var body: some View {
        ScrollView{
            LazyVStack(spacing: 16){
                ForEach(groupVM.joinRequestParticipantsList, id: \.id) {user in
                    UserRequestComponent(user: user, confirm: {
                        Task{
                            if try await APIClient.shared.acceptJoinRequestClub(clubId: club.id, userId: user.id, action:.ACCEPT) {
                                if let index = groupVM.joinRequestParticipantsList.firstIndex(where: { $0.id == user.id }) {
                                    groupVM.joinRequestParticipantsList.remove(at: index)
                                }
                            }
                        }
                        
                    }, delete: {
                        Task{
                            if try await APIClient.shared.acceptJoinRequestClub(clubId: club.id, userId: user.id, action:.DENY) {
                                if let index = groupVM.joinRequestParticipantsList.firstIndex(where: { $0.id == user.id }) {
                                    groupVM.joinRequestParticipantsList.remove(at: index)
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
                        if !groupVM.joinRequestLastPage {
                            isLoading = true
                            
                            Task{
                                try await groupVM.fetchClubJoinRequests(clubId: club.id)
                                isLoading = false
                                
                            }
                        }
                    }
            }
        }
        .refreshable{
            groupVM.joinRequestParticipantsList = []
            groupVM.joinRequestParticipantsPage = 0
            Task{
                do{
                    try await groupVM.fetchClubJoinRequests(clubId: club.id)
                } catch {
                    print("User list error:", error.localizedDescription)
                }
            }
        }
        .onAppear(){
            Task{
                do{
                    try await groupVM.fetchClubJoinRequests(clubId: club.id)
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
        
    }
}

#Preview {
    ClubJoinRequestsView(club: MockClub)
}
