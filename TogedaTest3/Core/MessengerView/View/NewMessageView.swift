//
//  NewMessageView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 24.11.23.
//

import SwiftUI

struct NewMessageView: View {
    @Environment(\.dismiss) var dismiss
    @State var searchText: String = ""
    @ObservedObject var chatVM: ChatViewModel
    @StateObject var newChatVM = NewChatViewModel()
//    @Binding var selectedUser: MiniUser?
    let size: ImageSize = .small
    @State var showGroupChat = false
    @State var searchUserResults: [MiniUser] = MiniUser.MOCK_MINIUSERS

    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("CONTACTS")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                LazyVStack {
                    ForEach(searchUserResults) { user in
                        VStack {
                            HStack {
                                Image(user.profilePhotos[0])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size.dimension, height: size.dimension)
                                    .clipShape(Circle())

                                Text(user.fullName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Spacer()
                            }
                            .onTapGesture {
                                dismiss()
                                chatVM.selectedUser = user
                                chatVM.showChat = true
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
                        result.fullName.lowercased().contains(searchText.lowercased())
                    }
                } else {
                    searchUserResults = MiniUser.MOCK_MINIUSERS
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showGroupChat){
                NewGroupChatView(newChatVM: newChatVM)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Make Group") {
                        showGroupChat = true
                    }
                }
            }
        }
    }
}

#Preview {
    NewMessageView(chatVM: ChatViewModel())
}
