//
//  Test2View.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.11.23.
//

import SwiftUI

struct Test2View: View {
    var miniUser: MiniUser = .MOCK_MINIUSERS[0]
    var user: User = .MOCK_USERS[0]
    var body: some View {
        VStack{
            VStack(alignment: .center) {
                TabView {
                    ForEach(miniUser.profilePhotos, id: \.self) { image in
                        Image(image)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                        
                    }
                    
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 500)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text(miniUser.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(alignment:.top, spacing: 15){
                        VStack(alignment: .leading, spacing: 15){
                            HStack(spacing: 5){
                                Image(systemName: "suitcase")
                                
                                Text("Graphic Designer")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.gray)
                            
                            
                            HStack(spacing: 5){
                                Image(systemName: "mappin.circle")
                                
                                Text(user.location.name)
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                            }
                            .foregroundColor(.gray)
                        }
                        Spacer()
//                        HStack(alignment: .top, spacing: 10) {
//                            userStats(value: String(user.friendIDs.count), title: "Friends")
//
//                            userStats(value: String(user.createdEventIDs.count), title: "Events")
//
//                        }

                    }
                    
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                

                

                    HStack(alignment:.center, spacing: 10) {
                        Button {
                            
                        } label: {
                            Text("Add Friend")
                                .normalTagTextStyle()
                                .frame(width: UIScreen.main.bounds.width/2 - 36)
                                .normalTagRectangleStyle()
                        }
                        Button {
                            
                        } label: {
                            Text("Message")
                                .normalTagTextStyle()
                                .frame(width: UIScreen.main.bounds.width/2 - 36)
                                .normalTagRectangleStyle()
                        }
                    }
                    .padding(.horizontal)
                }
                
                
            .padding(.bottom)
            .frame(width: UIScreen.main.bounds.width)
            .background(.bar)
            .cornerRadius(10)
        }
    }
    @ViewBuilder
    func userStats(value: String, title: String) -> some View {
        VStack(alignment: .center, spacing: 5) {
            Text(value)
                .font(.body)
                .bold()
            Text(title)
                .font(.footnote)
                .bold()
                .foregroundColor(.gray)
        }
        .frame(width: 50, height: 50)
        .normalTagRectangleStyle()
    }
    
}

#Preview {
    Test2View()
}
