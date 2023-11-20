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
    @State var minYValue: CGFloat = 0
    @State private var showImageSet: Bool = true
    
    var body: some View {
        NavigationView{
            ScrollView(showsIndicators: false){
                VStack(alignment: .center) {
                    //                        Text("\(initialMinYValue), \(minYValue)")
                    
                        if showImageSet {
                            TabView {
                                ForEach(user.profileImageUrl, id: \.self) { image in
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
                                Image(user.profileImageUrl[0])
                                    .resizable()
                                    .scaledToFill()
                                    .background(.gray)
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(20)
                                    .clipped()
                            }
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
                    
                    HStack(alignment: .top, spacing: 30) {
                        UserStats(value: String(user.friendIDs.count), title: "Friends")
                        Divider()
                        UserStats(value: String(user.eventIDs.count), title: "Events")
                        Divider()
                        UserStats(value: "\(user.rating)%", title: "Rating")
                    }
                    .padding(.vertical)
                    
                }
                .padding(.top, safeAreaInsets.top + 50) // if you move this part you might break the geomrty reader
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
                AboutTab(user: user)
                EventTab(vm: viewModel)
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
            //            .fullScreenCover(isPresented: $viewModel.showCompletedEvent, content: {
            //                CompletedEventView(viewModel: PostsViewModel(), post: viewModel.selectedPost, userViewModel: UserViewModel())
            //            })
        }
        .navigationViewStyle(.stack)
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: User.MOCK_USERS[0])
    }
}
