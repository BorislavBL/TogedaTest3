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
    @State var deleteSheet: Bool = false
    @State var isShowChangeDateAlert = false
    @State var newDate: Date = Date()
    
    
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
                    //                    ClubMemoryView(groupVM: vm, showImagesViewer: $showImagesViewer)
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
                print("Date: \(club.createdAt)")
                newDate = club.createdAt
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
                ImagesViewer(images: vm.images, selectedImage: $vm.selectedImage)
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
            .sheet(isPresented: $deleteSheet, content: {
                onDeleteSheet()
                
            })
            .scrollIndicators(.hidden)
            .edgesIgnoringSafeArea(.top)
            .frame(maxWidth: .infinity)
            .background(Color("testColor"))
            .navigationBarHidden(true)
            .navigationBarTitle("")
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
                } else if let not = not.alertBodyUserAddedToParticipants {
                    if let miniclub = not.club, miniclub.id == club.id {
                        vm.updateStatuses(miniUser: not.userAdded, miniClub: miniclub, club: $club)
                    }
                }
            }
        }
        .alert("Change Date", isPresented: $isShowChangeDateAlert) {
            if userVM.currentUser?.userRole == .ADMINISTRATOR {
                Button("Yes") {
                    Task{
                        if let response = try await APIClient.shared.changeClubDate(clubId: club.id, newDate: newDate) {
                            club = response
                        }
                    }
                }
            }
            Button("Cancel") {
                isShowChangeDateAlert = false
            }
        } message: {
            Text("Are you sure you want to change club's date?")
        }
    }
    
    func onDeleteSheet() -> some View {
        VStack(spacing: 30){
            Text("All of the information including the chat will be deleted!")
                .multilineTextAlignment(.leading)
                .font(.headline)
                .fontWeight(.bold)
            
            LoadingButton(action: {
                do{
                    try await clubsVM.deleteClub(clubId: club.id)
                    if let index = activityVM.activityFeed.firstIndex(where: {$0.club?.id == club.id}) {
                        activityVM.activityFeed.remove(at: index)
                    }
                    
                    if let chatRoomId = club.chatRoomId {
                        websocketVM.allChatRooms.removeAll(where: {$0.id == chatRoomId})
                    }
                    
                    DispatchQueue.main.async {
                        if navManager.selectionPath.count >= 1{
                            navManager.selectionPath.removeLast(1)
                        }
                        userVM.removeClub(club: club)
                    }
                } catch {
                    print(error)
                }
            }){
                Text("Delete")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(.red)
                    .cornerRadius(10)
            } loadingView: {
                Text("Deleting...")
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
        .presentationDetents([.fraction(0.2)])
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
                            self.clubsVM.refreshClubOnAction(club: response)
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
                
                
                //                    NavigationLink(value: SelectionPath.editClubView(club)) {
                if let chatRoomID = club.chatRoomId {
                    Button{
                        Task{
                            print("\(chatRoomID)")
                            do {
                                if let chatroom = try await APIClient.shared.getChat(chatId: chatRoomID) {
                                    print("\(chatroom)")
                                    DispatchQueue.main.async {
                                        navManager.resetMessage = true

                                        navManager.screen = .message
                                        navManager.selectionPath = []
                                        
                                        navManager.selectionPath.append(SelectionPath.userChat(chatroom: chatroom))
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
                if let user = userVM.currentUser, club.owner.id == user.id {
                    Button{
                        isEditing = true
                    } label:{
                        Image(systemName: "pencil")
                            .frame(width: 35, height: 35)
                            .background(.bar)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    }
                }
            }
            Menu{
                ShareLink(item: URL(string: createURLLink(postID: nil, clubID: club.id, userID: nil))!) {
                    Text("Share via")
                }
                
                if isOwner {
                    
                } else {
                    Button("Report") {
                        showReport = true
                    }
                    
                    
                    if userVM.currentUser?.userRole == .ADMINISTRATOR {
                        Menu {
                            Button(){
                                newDate = Date()
                                isShowChangeDateAlert = true
                                
                            } label:{
                                HStack(spacing: 20){
                                    Image(systemName: "arrow.up")
                                    Text("Now")
                                }
                                .foregroundStyle(.red)
                            }
                            
                            Button(){
                                newDate = Calendar.current.date(byAdding: .year, value: 1, to: club.createdAt)!
                                isShowChangeDateAlert = true
                                
                            } label:{
                                HStack(spacing: 20){
                                    Image(systemName: "arrow.up")
                                    Text("1 Year Up")
                                }
                                .foregroundStyle(.red)
                            }
                            
                            Button(){
                                newDate = Calendar.current.date(byAdding: .month, value: 1, to: club.createdAt)!
                                isShowChangeDateAlert = true
                                
                            } label:{
                                HStack(spacing: 20){
                                    Image(systemName: "arrow.up")
                                    Text("1 Month Up")
                                }
                                .foregroundStyle(.red)
                            }
                            
                            Button(){
                                newDate = Calendar.current.date(byAdding: .day, value: 7, to: club.createdAt)!
                                isShowChangeDateAlert = true
                                
                            } label:{
                                HStack(spacing: 20){
                                    Image(systemName: "arrow.up")
                                    Text("1 Week Up")
                                }
                                .foregroundStyle(.red)
                            }
                            
                            
                            Button{
                                newDate = Calendar.current.date(byAdding: .day, value: 1, to: club.createdAt)!
                                isShowChangeDateAlert = true
                                
                            } label:{
                                HStack(spacing: 20){
                                    Image(systemName: "arrow.up")
                                    Text("1 Day Up")
                                }
                                .foregroundStyle(.red)
                            }
                            
                            Button(role: .destructive){
                                newDate = Calendar.current.date(byAdding: .day, value: -1, to: club.createdAt)!
                                isShowChangeDateAlert = true
                                
                            } label:{
                                HStack(spacing: 20){
                                    Image(systemName: "arrow.down")
                                    Text("1 Day Down")
                                }
                                .foregroundStyle(.red)
                            }
                            
                            Button(role: .destructive){
                                newDate = Calendar.current.date(byAdding: .day, value: -7, to: club.createdAt)!
                                isShowChangeDateAlert = true
                                
                            } label:{
                                HStack(spacing: 20){
                                    Image(systemName: "arrow.down")
                                    Text("1 Week Down")
                                }
                                .foregroundStyle(.red)
                            }
                            
                            Button(role: .destructive){
                                newDate = Calendar.current.date(byAdding: .month, value: -1, to: club.createdAt)!
                                isShowChangeDateAlert = true
                                
                            } label:{
                                HStack(spacing: 20){
                                    Image(systemName: "arrow.down")
                                    Text("1 Month Down")
                                }
                                .foregroundStyle(.red)
                            }
                            
                            Button(role: .destructive){
                                newDate = Calendar.current.date(byAdding: .year, value: -1, to: club.createdAt)!
                                isShowChangeDateAlert = true
                                
                            } label:{
                                HStack(spacing: 20){
                                    Image(systemName: "arrow.down")
                                    Text("1 Year Down")
                                }
                                .foregroundStyle(.red)
                            }
                        } label: {
                            HStack(spacing: 20){
                                Image(systemName: "calendar")
                                Text("Change Date")
                            }
                            .foregroundStyle(.red)
                        }
                        
                        Button(role: .destructive){
                            deleteSheet = true
                        } label:{
                            HStack(spacing: 20){
                                Image(systemName: "trash")
                                Text("Delete")
                            }
                            .foregroundStyle(.red)
                        }
                        
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
        .environmentObject(WebSocketManager())
}
