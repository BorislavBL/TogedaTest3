//
//  ProfileView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    var user: User
    
    @StateObject var viewModel = ProfileViewModel()
    @State private var showImageSet = false
    @State var selectedPost: Post = Post.MOCK_POSTS[0]
    @State private var showCompletedEvent = false
    
    var body: some View {
        NavigationStack{
            ScrollView(showsIndicators: false){
                VStack(alignment: .center) {
                    if let profileImages = user.profileImageUrl {
                        if showImageSet {
                            TabView {
                                ForEach(profileImages, id: \.self) { image in
                                    Button{
                                        showImageSet = false
                                    } label:{
                                        Image(image)
                                            .resizable()
                                            .scaledToFill()
                                            .clipped()
                                    }
                                    
                                }
                                
                            }
                            .tabViewStyle(PageTabViewStyle())
                            .cornerRadius(10)
                            .frame(height: 400)
                            
                        } else {
                            
                            Button{
                                showImageSet = true
                            }label:{
                                Image(profileImages[0])
                                    .resizable()
                                    .scaledToFill()
                                    .background(.gray)
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(20)
                                    .clipped()
                            }
                        }
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
                    
                    //                    HStack(alignment:.center, spacing: 10) {
                    //                        Button {
                    //
                    //                        } label: {
                    //                            Text("Add Friend")
                    //                                .normalTagTextStyle()
                    //                                .frame(width: UIScreen.main.bounds.width/2 - 60)
                    //                                .normalTagRectangleStyle()
                    //                        }
                    //                        Button {
                    //
                    //                        } label: {
                    //                            Text("Message")
                    //                                .normalTagTextStyle()
                    //                                .frame(width: UIScreen.main.bounds.width/2 - 60)
                    //                                .normalTagRectangleStyle()
                    //                        }
                    //                    }
                    
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
                EventTab(selectedPost: $selectedPost, showCompletedView: $showCompletedEvent)
                ClubsTab()
                CalendarTab()
                
            }
            .edgesIgnoringSafeArea(.top)
            .frame(maxWidth: .infinity)
            .background(Color("testColor"))
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
                        
                        NavigationLink(destination: UserSettingsView()) {
                            Image(systemName: "gear")
                                .imageScale(.large)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showCompletedEvent, content: {
                CompletedEventView(viewModel: PostsViewModel(), post: selectedPost, userViewModel: UserViewModel())
            })
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: User.MOCK_USERS[0])
    }
}
