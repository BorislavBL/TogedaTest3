//
//  UserProfileView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.10.23.
//

import SwiftUI

struct UserProfileView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @Environment(\.dismiss) private var dismiss
    var user: User
    
    @StateObject var viewModel = ProfileViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack(alignment: .center) {
                if let profileImage = user.profileImageUrl {
                    Image(profileImage)
                        .resizable()
                        .scaledToFill()
                        .background(.gray)
                        .frame(width: 120, height: 120)
                        .cornerRadius(20)
                        .clipped()
                } else {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 10) {
                    Text(user.fullname)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 5){
                        Image(systemName: "suitcase")
                        
                        Text("Graphic Designer")
                            .font(.footnote)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.gray)
                    
                    if let from = user.from{
                        HStack(spacing: 5){
                            Image(systemName: "mappin.circle")
                            
                            Text(from)
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                        }
                        .foregroundColor(.gray)
                        
                    }
                }.padding(.vertical)
                
                HStack(alignment:.center, spacing: 10) {
                    Button {
                        
                    } label: {
                        Text("Add Friend")
                            .normalTagTextStyle()
                            .frame(width: UIScreen.main.bounds.width/2 - 60)
                            .normalTagRectangleStyle()
                    }
                    Button {
                        
                    } label: {
                        Text("Message")
                            .normalTagTextStyle()
                            .frame(width: UIScreen.main.bounds.width/2 - 60)
                            .normalTagRectangleStyle()
                    }
                }
                
                HStack(alignment: .top, spacing: 30) {
                    UserStats(value: String(user.friendIDs.count), title: "Friends")
                    Divider()
                    UserStats(value: String(user.eventIDs.count), title: "Events")
                    Divider()
                    UserStats(value: "\(user.rating)%", title: "Rating")
                }
                .padding(.vertical)
                
            }
            .padding(.top, safeAreaInsets.top + 50)
            .padding(.horizontal)
            .padding(.bottom)
            .frame(width: UIScreen.main.bounds.width)
            .background(.bar)
            .cornerRadius(10)
            
            BadgesTab()
            AboutTab(user: user)
            EventTab()
            ClubsTab()
            
            
        }
        .edgesIgnoringSafeArea(.top)
        .frame(maxWidth: .infinity)
        .background(Color("testColor"))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 5) { // adjust the spacing value as needed
                    Button {
                        print("")
                    } label: {
                        Image(systemName: "plus.square")
                            .imageScale(.large)
                            .foregroundColor(.accentColor)
                    }
                    
                    Button {
                        print("")
                    } label: {
                        Image(systemName: "gear")
                            .imageScale(.large)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {dismiss()}) {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
}

#Preview {
    UserProfileView(user: User.MOCK_USERS[0])
}
