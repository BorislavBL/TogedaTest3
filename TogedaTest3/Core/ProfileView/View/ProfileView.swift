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
    
    var body: some View {
        ScrollView{
            VStack(alignment: .center) {
                HStack(alignment: .center){
                    Spacer()
                    
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
                .padding(.horizontal)
                .padding(.bottom, 50)
                .frame(maxWidth: UIScreen.main.bounds.width)
                
                
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
                
//                if let bio = user.bio {
//                    Text(bio)
//                        .font(.callout)
//                        .fontWeight(.medium)
//                }
                
                HStack(alignment: .top, spacing: 30) {
                    UserStats(value: String(user.friendIDs.count), title: "Friends")
                    Divider()
                    UserStats(value: String(user.eventIDs.count), title: "Events")
                    Divider()
                    UserStats(value: "\(user.rating)%", title: "Rating")
                }
                .padding(.vertical)
                
                ProfileTabs(tabIndex: $viewModel.tabIndex, offset: $viewModel.offset)
            }
            .padding(.top, safeAreaInsets.top)
            .padding(.horizontal)
            .padding(.bottom)
            .frame(width: UIScreen.main.bounds.width)
            .background(.bar)
            .cornerRadius(30)
            
//            TabView(selection: $viewModel.tabIndex) {
//                Group{
//                    AboutTab(user: user)
//                        .tag(0)
//                    EventTab()
//                        .tag(1)
//                    ClubsTab()
//                        .tag(2)
//                    BadgesTab()
//                        .tag(3)
//                    CalendarTab()
//                        .tag(4)
//                }
//                .frame(maxWidth: .infinity)
//                .background(GeometryReader {
//                    Color.clear.preference(key: ViewRectKey.self,
//                                           value: [$0.frame(in: .local)])
//                })
//            }
//            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//            .frame(height: viewModel.rect.size.height + 1
//                   /* just to avoid page indicator overlap */)
//
//            .onPreferenceChange(ViewRectKey.self) { rects in
//                viewModel.rect = rects.first ?? .zero
//            }
   
//            HStack(alignment:.top, spacing: 0) {
//                switch viewModel.tabIndex{
//                case 0:
//                    AboutTab(user: user)
//                        .frame(width: UIScreen.main.bounds.width)
//                case 1:
//                    EventTab()
//                        .frame(width: UIScreen.main.bounds.width)
//                case 2:
//                    ClubsTab()
//                        .frame(width: UIScreen.main.bounds.width)
//                case 3:
//                    BadgesTab()
//                        .frame(width: UIScreen.main.bounds.width)
//                case 4:
//                    CalendarTab()
//                        .frame(width: UIScreen.main.bounds.width)
//                default:
//                    Text("none")
//                }
//            }
            
                    HStack(alignment:.top, spacing: 0) {
                        AboutTab(user: user)
                            .frame(width: UIScreen.main.bounds.width)
                        EventTab()
                            .frame(width: UIScreen.main.bounds.width)
                        ClubsTab()
                            .frame(width: UIScreen.main.bounds.width)
                        BadgesTab()
                            .frame(width: UIScreen.main.bounds.width)
                        CalendarTab()
                            .frame(width: UIScreen.main.bounds.width)
                    }
                    .offset(x: self.viewModel.offset)
                    .highPriorityGesture(DragGesture()

                        .onEnded({ (value) in
                            if value.translation.width > 30 {
                                print("right")
                                self.viewModel.changeView(left: false)

                            }
                            if -value.translation.width > 30{
                                print("left")
                                self.viewModel.changeView(left: true)
                            }
                        }))


        }
        .edgesIgnoringSafeArea(.top)
        .frame(maxWidth: .infinity)
        .background(Color("testColor"))
        
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: User.MOCK_USERS[1])
    }
}
