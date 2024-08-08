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
    var body: some View {
        ScrollView{
            LazyVStack(alignment: .leading, spacing: 15){
                ForEach([MockMiniUser], id: \.id) { user in
                    NavigationLink(value: SelectionPath.userChat(chatroom: mockChatRoom)){
                        HStack(alignment:.center, spacing: 10){
                            KFImage(URL(string: user.profilePhotos[0]))
                                .resizable()
                                .scaledToFill()
                                .frame(width: size.dimension, height: size.dimension)
                                .clipShape(Circle())
                            
                            Text("\(user.firstName) \(user.lastName)")
                                .multilineTextAlignment(.leading)
                                .fontWeight(.semibold)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
        .background()
    }
}

#Preview {
    ChatSearchView()
}
