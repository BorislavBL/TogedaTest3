//
//  GroupView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 2.01.24.
//

import SwiftUI

struct GroupView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var showImagesViewer: Bool = false
    @State var showShareSheet: Bool = false
    
    @State var club: Components.Schemas.ClubDto
    @StateObject var vm = GroupViewModel()
    @State var isEditing = false
    
    @EnvironmentObject var userVM: UserViewModel
    @State var showLeaveSheet = false
    
    var body: some View {
        ZStack(alignment: .top){
            ScrollView(){
                LazyVStack{
                    MainGroupView(showShareSheet: $showShareSheet, club: $club, vm: vm, showLeaveSheet: $showLeaveSheet, currentUser: userVM.currentUser)
                    GroupMembersView(club: club, groupVM: vm)
                    GroupAboutView(club: club)
                    if vm.clubEvents.count > 0 {
                        GroupEventsView(club: club, groupVM: vm)
                    }
                    GroupLocationView(club: club)
                    GroupMemoryView(groupVM: vm, showImagesViewer: $showImagesViewer)
                }
            }
            .onAppear(){
                Task{
                    vm.clubMembers = []
                    vm.membersPage = 0
                    try await vm.fetchClubMembers(clubId: club.id)
                }
            }
            .navigationDestination(isPresented: $isEditing) {
               EditGroupView(isActive: $isEditing, club: $club)
            }
            .fullScreenCover(isPresented: $showImagesViewer, content: {
                ImageViewer(images: vm.images, selectedImage: $vm.selectedImage)
            })
            .sheet(isPresented: $showShareSheet, content: {
                ShareView()
                    .presentationDetents([.fraction(0.8), .fraction(1)])
                    .presentationDragIndicator(.visible)
            })
            .sheet(isPresented: $showLeaveSheet, content: {
                onLeaveSheet()
                    .presentationDetents([.height(190)])
                    
            })
            .scrollIndicators(.hidden)
            .edgesIgnoringSafeArea(.top)
            .frame(maxWidth: .infinity)
            .background(Color("testColor"))
            .navigationBarBackButtonHidden(true)
            
            navbar()
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
            
            if club.permissions == .ALL || club.currentUserRole == .ADMIN {
                HStack(spacing: 5){
                    Button{
                        
                    } label: {
                        Image(systemName: "plus.square")
                            .rotationEffect(.degrees(90))
                            .frame(width: 35, height: 35)
                            .background(.bar)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    }
                }
                
                if let user = userVM.currentUser, club.owner.id == user.id {
//                    NavigationLink(value: SelectionPath.editClubView(club)) {
                    Button{
                        isEditing = true
                    } label:{
                        Image(systemName: "gear")
                            .rotationEffect(.degrees(90))
                            .frame(width: 35, height: 35)
                            .background(.bar)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    }
                }
            }
            
            
            Button{
                
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
                        if try await APIClient.shared.leaveClub(clubId: club.id) {
                            if let response = try await APIClient.shared.getClub(clubID: club.id) {
                                print("Get Club")
                                club = response
                                
                                vm.clubMembers = []
                                vm.membersPage = 0
                                
                                try await vm.fetchClubMembers(clubId: club.id)
                            }
                        }
                    } catch{
                        print(error)
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
    
}

#Preview {
    GroupView(club: MockClub)
        .environmentObject(UserViewModel())
}
