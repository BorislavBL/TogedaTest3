//
//  InboxView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 10.11.23.
//

import SwiftUI

struct InboxView: View {
    @State var searchText: String = ""
    @State var messages: [Message] = Message.MOCK_MESSAGES
    var body: some View {
        NavigationView{
            List{
                ForEach(messages){ message in
                    InboxRowView(message: message)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .padding(.bottom)
                .padding(.horizontal, 8)
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search")
            .listStyle(PlainListStyle())
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "square.and.pencil.circle.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(Color(.systemGray5))
                }
            }
        }
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
                        .foregroundColor(message.read ? Color(.systemBlue) : .gray)
                        .lineLimit(2)
                }
                
                HStack(alignment: .top){
                    Text(message.text)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    if message.read{
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
    InboxView()
}
