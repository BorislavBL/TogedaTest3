//
//  ChatSearchView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 22.11.23.
//

import SwiftUI
import Kingfisher

struct ChatSearchView: View {
    let size: ImageSize = .medium
    @ObservedObject var chatVM: ChatViewModel
    var body: some View {
        ScrollView{
            LazyVStack(alignment: .leading, spacing: 15){
                ForEach(chatVM.chatrooms, id: \.id) { chatroom in
                    NavigationLink(value: SelectionPath.userChat(chatroom: chatroom)){
                        HStack(alignment: .center, spacing: 12){
                            
                            switch chatroom._type{
                            case .CLUB:
                                if let club = chatroom.club {
                                    KFImage(URL(string: club.images[0]))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: size.dimension, height: size.dimension)
                                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                                }
                            case .FRIENDS:
                                if chatroom.previewMembers.count > 0 {
                                    KFImage(URL(string: chatroom.previewMembers[0].profilePhotos[0]))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: size.dimension, height: size.dimension)
                                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                                }
                            case .GROUP:
                                if let image = chatroom.image {
                                    KFImage(URL(string: image))
                                        .resizable()
                                        .scaledToFill()
                                        .background(.gray)
                                        .frame(width: size.dimension, height: size.dimension)
                                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                                } else if chatroom.previewMembers.count > 1 {
                                    ZStack(alignment:.top){
                                        
                                        KFImage(URL(string: chatroom.previewMembers[0].profilePhotos[0]))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 2 * size.dimension/3, height: 2 * size.dimension/3)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color("base"), lineWidth: 2)
                                            )
                                            .offset(y: -size.dimension/6)
                                        
                                        KFImage(URL(string: chatroom.previewMembers[1].profilePhotos[0]))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 2 * size.dimension/3, height: 2 * size.dimension/3)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color("base"), lineWidth: 2)
                                            )
                                            .offset(x: size.dimension/6, y: size.dimension/6)
                                        
                                    }
                                    .offset(y: size.dimension/6)
                                    .padding([.trailing, .bottom], size.dimension/3)
                                }
                            case .POST:
                                if let post = chatroom.post {
                                    KFImage(URL(string: post.images[0]))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: size.dimension, height: size.dimension)
                                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                                }
                                
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack{
                                    switch chatroom._type{
                                    case .CLUB:
                                        if let club = chatroom.club {
                                            Text("\(club.title)")
                                                .lineLimit(1)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                    case .FRIENDS:
                                        if chatroom.previewMembers.count > 0 {
                                            Text("\(chatroom.previewMembers[0].firstName) \(chatroom.previewMembers[0].lastName)")
                                                .lineLimit(1)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                    case .GROUP:
                                        if let title = chatroom.title {
                                            Text("\(title)")
                                                .lineLimit(1)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                        else if chatroom.previewMembers.count > 1 {
                                            Text("\(chatroom.previewMembers[0].firstName), \(chatroom.previewMembers[1].firstName)")
                                                .lineLimit(1)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                    case .POST:
                                        if let post = chatroom.post {
                                            Text("\(post.title)")
                                                .lineLimit(1)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                        
                                    }
                                    
                                    
                                    Spacer(minLength: 10)
                                }
                            }
                        }
                    }
                }
                
                if chatVM.isLoading == .loading {
                    ProgressView() // Show spinner while loading
                }
                
                Rectangle()
                    .frame(width: 0, height: 0)
                    .onAppear {
                        if !chatVM.chatroomsLastPage{
                            if chatVM.isLoading == .loaded {
                                chatVM.isLoading = .loading
                                Task{
                                    try await chatVM.searchChatrooms()
                                }
                            }
                        }
                    }
            }
            .padding()
        }
        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
        .background(.bar)
    }
}

#Preview {
    ChatSearchView(chatVM: ChatViewModel())
}
