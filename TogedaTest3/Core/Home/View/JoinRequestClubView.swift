//
//  JoinRequestClubView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.06.24.
//

import SwiftUI

struct JoinRequestClubView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var clubsVM: ClubsViewModel
    @EnvironmentObject var activityVM: ActivityViewModel

    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var club: Components.Schemas.ClubDto
    @EnvironmentObject var navManager: NavigationManager
    @Binding var isActive: Bool
    var refreshParticipants: () -> ()
    
    @State var loadingState: LoadingCases = .loaded
 
    var body: some View {
        VStack(spacing: 30){
            if loadingState == .loaded {
                if !isOwner {
                    switch club.currentUserStatus{
                    case .IN_QUEUE:
                        Text("Would you like to cancel the request?")
                            .font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        
                        Button {
                            Task{
                                loadingState = .loading
                                defer{ loadingState = .loaded }
                                do{
                                    if try await APIClient.shared.cancelJoinRequestForClub(clubId: club.id) != nil {
                                        if let response = try await APIClient.shared.getClub(clubID: club.id) {
                                            club = response
                                            clubsVM.refreshClubOnAction(club: response)
                                            activityVM.localRefreshClubOnAction(club: response)
                                            refreshParticipants()
                                            isActive = false
                                        }
                                    }
                                } catch{
                                    print(error)
                                    isActive = false
                                }
                            }
                        } label: {
                            Text("Cancel")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .cornerRadius(10)
                        }
                    case .NOT_PARTICIPATING:
                        Text("Would you like to join the \(club.title) club?")
                            .font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        
                        Button {
                            Task{
                                loadingState = .loading
                                defer{ loadingState = .loaded }
                                if try await APIClient.shared.joinClub(clubId: club.id) != nil {
                                    if let response = try await APIClient.shared.getClub(clubID: club.id) {
                                        clubsVM.refreshClubOnAction(club: response)
                                        activityVM.localRefreshClubOnAction(club: response)
                                        userViewModel.addClub(club: response)
                                        club = response
                                        isActive = false
                                    }
                                }
                            }
                        } label: {
                            Text("Join")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .cornerRadius(10)
                        }
                    case .PARTICIPATING:
                        Text("Are you sure you want to leave the club?")
                            .font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        
                        Button {
                            Task{
                                loadingState = .loading
                                defer{ loadingState = .loaded }
                                if try await APIClient.shared.leaveClub(clubId: club.id) != nil {
                                    if let response = try await APIClient.shared.getClub(clubID: club.id) {
                                        clubsVM.refreshClubOnAction(club: response)
                                        activityVM.localRefreshClubOnAction(club: response)
                                        userViewModel.removeClub(club: response)
                                        
                                        club = response
                                        refreshParticipants()
                                        isActive = false
                                    }
                                }
                            }
                        } label: {
                            Text("Leave")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .cornerRadius(10)
                        }
                    }
                } else {
                    Text("You are the owner of the club. Leaving is not an option!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    
                    Button {
                        isActive = false
                    } label: {
                        Text("Close")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                    }
                }
            } else {
                Text("Your request is being processed.")
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                loadingButton()
            }
        }
        .padding()
        .presentationDetents([.height(250)])
    }
    
    @ViewBuilder
    func loadingButton() -> some View {
        Text("Loading...")
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color("blackAndWhite"))
            .foregroundColor(Color("testColor"))
            .cornerRadius(10)
    }
    
    var isOwner: Bool {
        if let user = userViewModel.currentUser, user.id == club.owner.id{
            return true
        } else {
            return false
        }
    }
}

#Preview {
    JoinRequestClubView(club: .constant(MockClub), isActive: .constant(true), refreshParticipants: {})
        .environmentObject(ClubsViewModel())
        .environmentObject(ActivityViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(NavigationManager())
}
