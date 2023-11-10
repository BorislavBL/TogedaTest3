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
    var miniUser: MiniUser
    var user: User? {
        User.findUser(byId: miniUser.id)
    }
    let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
    @StateObject var viewModel = ProfileViewModel()
    
    @State var minYValue: CGFloat = 0
    @State private var showImageSet: Bool = true
    
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack(alignment: .center) {
                    if showImageSet {
                        TabView {
                            ForEach(miniUser.profileImageUrl, id: \.self) { image in

                                    Image(image)
                                        .resizable()
                                        .scaledToFill()
                                        .clipped()
                                
                                
                            }
                            
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .cornerRadius(10)
                        .frame(height: 400)
                        
                    } else {
                        
                        Button{
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            showImageSet = true
                        }label:{
                            Image(miniUser.profileImageUrl[0])
                                .resizable()
                                .scaledToFill()
                                .background(.gray)
                                .frame(width: 120, height: 120)
                                .cornerRadius(20)
                                .clipped()
                        }
                    }
                
                
                VStack(spacing: 10) {
                    Text(miniUser.fullname)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 5){
                        Image(systemName: "suitcase")
                        
                        Text("Graphic Designer")
                            .font(.footnote)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.gray)
                    
                    if let from = miniUser.from{
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
                
                if miniUser.id != userId{
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
                }
                
                HStack(alignment: .top, spacing: 30) {
                    UserStats(value: String(user?.friendIDs.count ?? 0), title: "Friends")
                    Divider()
                    UserStats(value: String(user?.eventIDs.count ?? 0), title: "Events")
                    Divider()
                    UserStats(value: "\(user?.rating ?? 0)%", title: "Rating")
                }
                .padding(.vertical)
                
            }
            .padding(.top, safeAreaInsets.top + 50)
            .padding(.horizontal)
            .padding(.bottom)
            .frame(width: UIScreen.main.bounds.width)
            .background(.bar)
            .cornerRadius(10)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .frame(width: 0, height: 0)
                        .onChange(of: geo.frame(in: .global).minY) { oldMinY,  newMinY in
                            minYValue = newMinY
                            if newMinY >= 45 && !showImageSet{
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                showImageSet = true
                            } else if newMinY < -15 && showImageSet{
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                showImageSet = false
                            }
                        }
                }
            )
            
            BadgesTab()
            if let user = user {
                AboutTab(user: user)
            }
            EventTab(vm: viewModel)
            ClubsTab()
            if miniUser.id == userId {
                CalendarTab()
            }
            
            
        }
        .edgesIgnoringSafeArea(.top)
        .frame(maxWidth: .infinity)
        .background(Color("testColor"))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            if miniUser.id == userId {
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
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {dismiss()}) {
                    Image(systemName: "chevron.left")
                }
            }
        }
//        .fullScreenCover(isPresented: $viewModel.showCompletedEvent, content: {
//            CompletedEventView(viewModel: PostsViewModel(), post: viewModel.selectedPost, userViewModel: UserViewModel())
//        })
    }
}

#Preview {
    UserProfileView(miniUser: MiniUser.MOCK_MINIUSERS[0])
}
