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
    
    var clubID: String
    @StateObject var vm = GroupViewModel()
    
    let userID = UserDefaults.standard.string(forKey: "userId") ?? ""
    
    var clubMember: ClubMember? {
        return vm.club.members.first { ClubMember in
            ClubMember.userID == userID
        }
    }
    
    var body: some View {
        ZStack(alignment: .top){
            ScrollView(){
                LazyVStack{
                    MainGroupView(groupVM: vm, showShareSheet: $showShareSheet, userID: userID)
                    GroupMembersView(groupVM: vm, userID: userID)
                    GroupAboutView(groupVM: vm)
                    GroupEventsView(groupVM: vm)
                    GroupLocationView(groupVM: vm)
                    GroupMemoryView(groupVM: vm, showImagesViewer: $showImagesViewer)
                }
            }
            .onAppear(){
                vm.fetchClub(clubID: clubID)
            }
            .fullScreenCover(isPresented: $showImagesViewer, content: {
                ImageViewer(images: vm.images, selectedImage: $vm.selectedImage)
            })
            .sheet(isPresented: $showShareSheet, content: {
                ShareView()
                    .presentationDetents([.fraction(0.8), .fraction(1)])
                    .presentationDragIndicator(.visible)
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
            
            if let member = clubMember {
                HStack(spacing: 5){
                    Button{
                        
                    } label: {
                        Image(systemName: "plus.square")
                            .rotationEffect(.degrees(90))
                            .frame(width: 35, height: 35)
                            .background(.bar)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    }
                    
                    if member.status == "Admin" {
                        NavigationLink(destination: GroupSettingsView(vm: vm)) {
                            Image(systemName: "gear")
                                .rotationEffect(.degrees(90))
                                .frame(width: 35, height: 35)
                                .background(.bar)
                                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        }
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
    
}

#Preview {
    GroupView(clubID: Club.MOCK_CLUBS[0].id)
}
