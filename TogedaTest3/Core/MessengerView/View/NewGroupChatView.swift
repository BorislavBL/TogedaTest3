//
//  NewGroupChatView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 28.11.23.
//

import SwiftUI
import WrappingHStack

struct NewGroupChatView: View {
    @Environment(\.dismiss) var dismiss
    @State var searchText: String = ""
    let size: ImageSize = .small
    @State var searchUserResults: [MiniUser] = MiniUser.MOCK_MINIUSERS
    @State var selectedUsers: [MiniUser] = []
    
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
                            ForEach(selectedUsers, id: \.id) { user in
                                ParticipantsChatTags(user: user){
                                    selectedUsers.removeAll(where: { $0 == user })
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
                    ForEach(searchUserResults) { user in
                        VStack {
                            Button{
                                if selectedUsers.contains(user) {
                                    selectedUsers.removeAll(where: { $0 == user })
                                } else {
                                    selectedUsers.append(user)
                                }
                            } label:{
                                HStack {
                                    if selectedUsers.contains(user){
                                        Image(systemName: "checkmark.circle.fill")
                                            .imageScale(.large)
                                            .foregroundStyle(.blue)
                                    } else {
                                        Image(systemName: "circle")
                                            .imageScale(.large)
                                            .foregroundStyle(.gray)
                                    }
                                    
                                    Image(user.profileImageUrl[0])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: size.dimension, height: size.dimension)
                                        .clipShape(Circle())
                                    
                                    Text(user.fullname)
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
                if !searchText.isEmpty {
                    searchUserResults = MiniUser.MOCK_MINIUSERS.filter{result in
                        result.fullname.lowercased().contains(searchText.lowercased())
                    }
                } else {
                    searchUserResults = MiniUser.MOCK_MINIUSERS
                }
            }
            .navigationTitle("New Group")
            .searchable(text: $searchText)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedUsers.count > 0 {
                        Button("Next") {
                            
                        }
                    } else {
                        Text("Next")
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
}

struct ParticipantsChatTags: View {
    var user: MiniUser
    let size: ImageSize = .xxSmall
    @State var clicked = false
    var action: () -> Void
    var body: some View {
        if clicked {
            Button{action()} label:{
                HStack{
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                        
                    
                    Text(user.fullname)
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
                    Image(user.profileImageUrl[0])
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(Circle())
                    
                    Text(user.fullname)
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
    NewGroupChatView()
}

