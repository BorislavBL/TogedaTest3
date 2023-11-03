//
//  NotificationView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.11.23.
//

import SwiftUI

struct NotificationView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false){
            FriedRequestView()
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
    }
}

struct FriedRequestView: View {
    var user: MiniUser = MiniUser.MOCK_MINIUSERS[0]
    var body: some View {
        HStack{
            NavigationLink(destination: UserProfileView(miniUser: user)){
                HStack(alignment:.top){
                    if let images = user.profileImageUrl {
                        Image(images[0])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 45, height: 45)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                            .frame(width: 45, height: 45)
                    }
                    
                    
                    Text(user.fullname)
                        .font(.footnote)
                        .fontWeight(.semibold) +
                    
                    
                    Text(" Sends you a Friend Request.")
                        .font(.footnote) +
                    
                    Text(" 1 min ago")
                        .foregroundStyle(.gray)
                        .font(.footnote)
                }
                .multilineTextAlignment(.leading)
            }
            
            Spacer(minLength: 10)
            
            Button{} label:{
                Text("Confirm")
                    .foregroundColor(.white)
                    .font(.callout)
                    .fontWeight(.bold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(.blue)
                    .cornerRadius(10)
            }
        }
    }
}

#Preview {
    NotificationView()
}
