//
//  ChatSearchView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 22.11.23.
//

import SwiftUI

struct ChatSearchView: View {
    let size: ImageSize = .medium
    var body: some View {
        ScrollView{
            LazyVStack(alignment: .leading, spacing: 15){
                ForEach(User.MOCK_USERS, id: \.id) { user in
                    NavigationLink(value: user){
                        HStack(alignment:.center, spacing: 10){
                            Image(user.profileImageUrl[0])
                                .resizable()
                                .scaledToFill()
                                .frame(width: size.dimension, height: size.dimension)
                                .clipShape(Circle())
                            
                            Text(user.fullname)
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
        }
    }
}

#Preview {
    ChatSearchView()
}
