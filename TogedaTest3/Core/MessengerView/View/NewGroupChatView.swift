//
//  NewGroupChatView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 28.11.23.
//

import SwiftUI
import WrappingHStack
import Kingfisher

struct NewGroupChatView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var newChatVM: NewChatViewModel
    @State var searchText: String = ""
    let size: ImageSize = .small
    @State var searchUserResults: [Components.Schemas.GetFriendsDto] = []
    @State var selectedUsers: [Components.Schemas.GetFriendsDto] = []
    @State private var showNewGroupChatCreateView = false
    
    var body: some View {
            ScrollView {
//                TextField("To: ", text: $searchText)
//                    .frame(height: 44)
//                    .padding(.leading)
//                //                    .background(Color(.systemGroupedBackground))
//                    .background(Color(.tertiarySystemFill))
                
                if selectedUsers.count > 0{
                    ScrollView{
                        WrappingHStack(alignment: .topLeading){
                            ForEach(selectedUsers, id: \.user.id) { user in
                                ParticipantsChatTags(user: user){
                                    selectedUsers.removeAll(where: { $0.user.id == user.user.id })
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxHeight: 100)
                }
                
                Text("CONTACTS")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                
                LazyVStack {
                    ForEach(searchUserResults, id: \.user.id) { user in
                        VStack {
                            Button{
                                if selectedUsers.contains(where:{ $0.user.id == user.user.id}) {
                                    selectedUsers.removeAll(where: { $0.user.id == user.user.id })
                                } else {
                                    selectedUsers.append(user)
                                }
                            } label:{
                                HStack {
                                    if selectedUsers.contains(where:{ $0.user.id == user.user.id}){
                                        Image(systemName: "checkmark.circle.fill")
                                            .imageScale(.large)
                                            .foregroundStyle(.blue)
                                    } else {
                                        Image(systemName: "circle")
                                            .imageScale(.large)
                                            .foregroundStyle(.gray)
                                    }
                                    
                                    KFImage(URL(string: user.user.profilePhotos[0]))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: size.dimension, height: size.dimension)
                                        .clipShape(Circle())
                                    
                                    Text("\(user.user.firstName) \(user.user.lastName)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                }
                            }
                            
                            Divider()
                                .padding(.leading, 40)
                        }
                        .padding(.leading)
                    }
                }
            }
            
            .onChange(of: searchText){
//                if !searchText.isEmpty {
//                    searchUserResults = MiniUser.MOCK_MINIUSERS.filter{result in
//                        result.fullName.lowercased().contains(searchText.lowercased())
//                    }
//                } else {
//                    searchUserResults = MiniUser.MOCK_MINIUSERS
//                }
            }
            .navigationTitle("New Group")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button{
                        dismiss()
                    } label:{
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedUsers.count > 0 {
                        Button{
                            showNewGroupChatCreateView = true
                        } label:{Text("Next")}
                    } else {
                        Text("Next")
                            .foregroundStyle(.gray)
                    }
                }
            }
            .navigationDestination(isPresented: $showNewGroupChatCreateView) {
                NewGroupChatCreateView(newChatVM: newChatVM)
            }
        
        }
}

struct ParticipantsChatTags: View {
    var user: Components.Schemas.GetFriendsDto
    let size: ImageSize = .xxSmall
    @State var clicked = false
    var action: () -> Void
    var body: some View {
        if clicked {
            Button{action()} label:{
                HStack{
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                        
                    
                    Text("\(user.user.firstName) \(user.user.lastName)")
                        .font(.subheadline)

                }
                .frame(height: size.dimension)
                .padding(.horizontal, 8)
                .background(Color(.tertiarySystemFill))
                .clipShape(Capsule())
            }
        } else {
            Button{clicked = true} label:{
                HStack{
                    KFImage(URL(string: user.user.profilePhotos[0]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(Circle())
                    
                    Text("\(user.user.firstName) \(user.user.lastName)")
                        .font(.subheadline)
                        .padding(.trailing, 8)
                }
                .background(Color(.tertiarySystemFill))
                .clipShape(Capsule())
            }
        }
        
    }
}

#Preview {
    NewGroupChatView(newChatVM: NewChatViewModel())
}

