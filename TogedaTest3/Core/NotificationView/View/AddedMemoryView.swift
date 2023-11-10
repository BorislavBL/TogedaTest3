//
//  AddedMemoryView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.11.23.
//

import SwiftUI

struct AddedMemoryView: View {
    let size: ImageSize = .medium
    var user: MiniUser = MiniUser.MOCK_MINIUSERS[0]
    var body: some View {
        VStack {
            NavigationLink(destination: UserProfileView(miniUser: user)){
                HStack(alignment:.top){
                        Image(user.profileImageUrl[0])
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .clipShape(Circle())
                    
                }
                VStack(alignment:.leading){
                    Text(user.fullname)
                        .font(.footnote)
                        .fontWeight(.semibold) +
                    
                    
                    Text(" Added Memory to an event you participated in.")
                        .font(.footnote) +
                    
                    Text(" 1 min ago")
                        .foregroundStyle(.gray)
                        .font(.footnote)
                    
                }
                .multilineTextAlignment(.leading)
                
                Spacer(minLength: 5)
                
                Image("event_1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.dimension, height: size.dimension)
                    .cornerRadius(10)
                    .clipped()
            }
            
        }
    }
}

#Preview {
    AddedMemoryView()
}
