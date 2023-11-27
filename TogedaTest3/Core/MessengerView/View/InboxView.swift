//
//  InboxView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 10.11.23.
//

import SwiftUI

struct InboxView: View {
    @ObservedObject var chatVM: ChatViewModel
    @State private var showNewMessageView = false
    @State var searchText: String = ""
    @State var messages: [Message] = Message.MOCK_MESSAGES
    @State var isSearching: Bool = false
    @State var searchUserResults: [MiniUser] = MiniUser.MOCK_MINIUSERS
    
    var body: some View {
        NavigationView{
            List{
                ForEach(messages){ message in
                    ZStack{
                        NavigationLink(destination: ChatView(user: message.user ?? MiniUser.MOCK_MINIUSERS[0])){
                            EmptyView()
                        }

                        .opacity(0)
                        InboxRowView(message: message)
                    }
                    
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .padding(.top)
                .padding(.horizontal)
            }
            .searchable(text: $searchText, isPresented: $isSearching, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search")
            .listStyle(PlainListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Chats")
            .scrollIndicators(.hidden)
            .overlay{
                if isSearching {
                    ChatSearchView()
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
            .fullScreenCover(isPresented: $showNewMessageView, content: {
                NewMessageView(chatVM: chatVM)
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "square.and.pencil.circle.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(Color.black, Color(.systemGray5))
                        .onTapGesture {
                            showNewMessageView.toggle()
                            chatVM.selectedUser = nil
                        }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct InboxRowView: View {
    var message: Message
    var size: ImageSize = .medium
    var body: some View {
        HStack(alignment: .top, spacing: 12){
            if let user = message.user{
                Image(user.profileImageUrl[0])
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.dimension, height: size.dimension)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack{
                    if let user = message.user{
                        Text(user.fullname)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer(minLength: 10)
                    
                    Text("\(message.timestamp.formatted())")
                        .font(.footnote)
                        .foregroundColor(!message.read ? Color(.systemBlue) : .gray)
                        .lineLimit(2)
                }
                
                HStack(alignment: .top){
                    Text(message.text)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    if !message.read{
                        Spacer(minLength: 10)
                        
                        Circle()
                            .fill(Color(.systemBlue))
                            .frame(width: 12, height: 12, alignment: .leading)
                    }
                    
                }
            }
        }
    }
}

#Preview {
    InboxView(chatVM: ChatViewModel())
}
