//
//  GroupView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 2.01.24.
//

import SwiftUI

struct ClubView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var showImagesViewer: Bool = false
    @State var showShareSheet: Bool = false
    @State var clubNotFound: Bool = false
    
    @State var club: Components.Schemas.ClubDto
    @StateObject var vm = ClubViewModel()
    @State var isEditing = false
    @EnvironmentObject var clubsVM: ClubsViewModel
    @EnvironmentObject var activityVM: ActivityViewModel
    @EnvironmentObject var navManager: NavigationManager
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var websocketVM: WebSocketManager
    
    @State var showLeaveSheet = false
    @State var showCancelSheet = false
    @State var showCreateEvent = false
    
    @State var showOption = false
    
    @State var showReport = false
    
    @State var Init = true

    var body: some View {
        ZStack(alignment: .top){
            ScrollView(){
                LazyVStack{
                    MainClubView(showShareSheet: $showShareSheet, club: $club, vm: vm, showLeaveSheet: $showLeaveSheet, showCancelSheet: $showCancelSheet, currentUser: userVM.currentUser)
                    ClubMembersView(club: club, groupVM: vm)
                    ClubAboutView(club: club)
                    if vm.clubEvents.count > 0 {
                        ClubEventsView(club: club, groupVM: vm)
                    }
                    ClubLocationView(club: club)
                    ClubMemoryView(groupVM: vm, showImagesViewer: $showImagesViewer)
                }
            }
            .refreshable {
                Task{
                    if let response = try await APIClient.shared.getClub(clubID: club.id) {
                        if let index = clubsVM.feedClubs.firstIndex(where: { $0.id == club.id }) {
                            clubsVM.feedClubs[index] = response
                        }
                        
                        if let index = activityVM.activityFeed.firstIndex(where: { $0.club?.id == club.id }) {
                            activityVM.activityFeed[index].club = response
                        }
                        
                        club = response
                    }
                    
                    vm.clubMembers = []
                    vm.membersPage = 0

                    vm.clubEvents = []
                    vm.clubEventsPage = 0
                    
                    try await fetchAllData(clubId: club.id)
                    
                }
            }
            .onAppear(){
                Task{
                    if Init {
                        vm.clubEvents = []
                        vm.clubEventsPage = 0
                        
                        vm.clubMembers = []
                        vm.membersPage = 0
                        
                        try await fetchAllData(clubId: club.id)
                    } else {
                        vm.clubMembers = []
                        vm.membersPage = 0
                        try await vm.fetchClubMembers(clubId: club.id)
                    }
                }
            }
            .navigationDestination(isPresented: $isEditing) {
               EditClubView(isActive: $isEditing, club: $club)
            }
            .fullScreenCover(isPresented: $showImagesViewer, content: {
                ImageViewer(images: vm.images, selectedImage: $vm.selectedImage)
            })
            .sheet(isPresented: $showShareSheet, content: {
                ShareView(club: club)
                    .presentationDetents([.fraction(0.8), .fraction(1)])
                    .presentationDragIndicator(.visible)
            })
            .sheet(isPresented: $showLeaveSheet, content: {
                onLeaveSheet()
                    .presentationDetents([.height(190)])
                    
            })
            .sheet(isPresented: $showReport, content: {
                ReportClubView(club: club, isActive: $showReport)
            })
            .sheet(isPresented: $showCancelSheet, content: {
                onCancelSheet()
                    .presentationDetents([.height(190)])
                    
            })
            .fullScreenCover(isPresented: $showCreateEvent, content: {
                CreateEventView(fromClub: club)
            })
            .scrollIndicators(.hidden)
            .edgesIgnoringSafeArea(.top)
            .frame(maxWidth: .infinity)
            .background(Color("testColor"))
            .navigationBarBackButtonHidden(true)
            
            navbar()
        }
        .overlay{
            if clubNotFound {
                PageNotFoundView()
            }
        }
        .swipeBack()
        .onChange(of: websocketVM.newNotification){ old, new in
            print("triggered 1")
            if let not = new {
                print("triggered 2")
                if let not = not.alertBodyAcceptedJoinRequest {
                    if club.askToJoin{
                        if let miniclub = not.club, miniclub.id == club.id {
                            vm.updateStatuses(miniUser: not.acceptedUser, miniClub: miniclub, club: $club)
                        }
                    }
                }
            }
        }
    }
    

    func fetchAllData(clubId: String) async throws {
        // Use a task group to fetch all data concurrently
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    try await vm.fetchClubMembers(clubId: clubId)
                } catch {
                    print("Error fetching user posts: \(error)")
                }
            }
            
            group.addTask {
                do {
                    try await vm.fetchClubEvents(clubId: clubId)
                } catch {
                    print("Error fetching user clubs: \(error)")
                }
            }
            
            group.addTask {
                do {
                    if let response = try await APIClient.shared.getClub(clubID: clubId) {
                        DispatchQueue.main.async {
                            self.club = response
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.clubNotFound = true
                        }
                    }
                } catch {
                    print("Error fetching user clubs: \(error)")
                }
            }
        }
    }
    
    
    @ViewBuilder
    func navbar() -> some View {
        HStack(alignment: .center){
            Button(action: {dismiss()}) {
                Image(systemName: "chevron.left")
                    .frame(width: 35, height: 35)
                    .background(.bar)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            }
            
            Spacer()
            
            if club.currentUserStatus == .PARTICIPATING && (club.permissions == .ALL || club.currentUserRole == .ADMIN) {
                HStack(spacing: 5){
                    Button{
                        showCreateEvent = true
                    } label: {
                        Image(systemName: "plus.square")
                            .frame(width: 35, height: 35)
                            .background(.bar)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    }
                }
                
                if let user = userVM.currentUser, club.owner.id == user.id {
//                    NavigationLink(value: SelectionPath.editClubView(club)) {
                    if let chatRoomID = club.chatRoomId {
                        Button{
                            Task{
                                print("\(chatRoomID)")
                                do {
                                    if let chatroom = try await APIClient.shared.getChat(chatId: chatRoomID) {
                                        print("\(chatroom)")
                                        DispatchQueue.main.async {
                                            self.navManager.screen = .message
                                            self.navManager.selectionPath = [.userChat(chatroom: chatroom)]
                                        }
                                    } else {
                                        print("nil")
                                    }
                                } catch {
                                    print(error)
                                }
                            }
                        } label:{
                            Text("Go To Chat")
                                .font(.footnote)
                                .bold()
                                .frame(height: 35)
                                .padding(.horizontal)
                                .background(.bar)
                                .clipShape(Capsule())
                        }
                    } else {
                        Button{
                            Task{
                                if let chatRoomId = try await APIClient.shared.createChatForClub(clubId: club.id) {
                                    if let chatroom = try await APIClient.shared.getChat(chatId: chatRoomId) {
                                        print("\(chatroom)")
                                        DispatchQueue.main.async {
                                            self.navManager.screen = .message
                                            self.navManager.selectionPath = [.userChat(chatroom: chatroom)]
                                        }
                                    }
                                }
                            }
                        } label:{
                            Text("Create Chat")
                                .font(.footnote)
                                .bold()
                                .frame(height: 35)
                                .padding(.horizontal)
                                .background(.bar)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Button{
                        isEditing = true
                    } label:{
                        Image(systemName: "pencil")
                            .frame(width: 35, height: 35)
                            .background(.bar)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    }
                }
            } else {
                Menu{
                    ShareLink(item: URL(string: "https://www.youtube.com/")!) {
                        Text("Share via")
                    }
                    
                    if isOwner {

                    } else {
                        Button("Report") {
                            showReport = true
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .frame(width: 35, height: 35)
                        .background(.bar)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                }
                
            }
        }
        .padding(.horizontal)
    }
    
    func onLeaveSheet() -> some View {
        VStack(spacing: 30){
            Text("All of your events related to the club will be deleted upon leaving!")
                .multilineTextAlignment(.leading)
                .font(.headline)
                .fontWeight(.bold)
            
            Button{
                Task{
                    do{
                        if try await APIClient.shared.leaveClub(clubId: club.id) != nil {
                            if let response = try await APIClient.shared.getClub(clubID: club.id) {
                                print("Get Club")
                                club = response
                                clubsVM.refreshClubOnAction(club: response)
                                activityVM.localRefreshClubOnAction(club: response)
                                
                                vm.clubMembers = []
                                vm.membersPage = 0
                                
                                try await vm.fetchClubMembers(clubId: club.id)
                                showLeaveSheet = false
                            }
                        }
                    } catch{
                        print(error)
                        showLeaveSheet = false
                    }
                }

            } label:{
                Text("Leave")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(.red)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    func onCancelSheet() -> some View {
        VStack(spacing: 30){
            Text("Are you sure you would like to cancel the request?")
                .multilineTextAlignment(.leading)
                .font(.headline)
                .fontWeight(.bold)
            
            Button{
                Task{
                    do{
                        if try await APIClient.shared.cancelJoinRequestForClub(clubId: club.id) != nil {
                            if let response = try await APIClient.shared.getClub(clubID: club.id) {
                                club = response
                                clubsVM.refreshClubOnAction(club: response)
                                activityVM.localRefreshClubOnAction(club: response)
                                showCancelSheet = false
                            }
                        }
                    } catch{
                        print(error)
                        showCancelSheet = false
                    }
                }

            } label:{
                Text("Cancel")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(.red)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    var isOwner: Bool {
        if let user = userVM.currentUser, user.id == club.owner.id{
            return true
        } else {
            return false
        }
    }
    
}

#Preview {
    ClubView(club: MockClub)
        .environmentObject(UserViewModel())
        .environmentObject(NavigationManager())
        .environmentObject(ClubsViewModel())
        .environmentObject(ActivityViewModel())
}
