//
//  EventTab.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct EventTab: View {
    var userID: String
    
    @State var lastPage: Bool = false
    @Binding var posts: [Components.Schemas.PostResponseDto]
    @Binding var createEvent: Bool
    @Binding var count: Int64
    @EnvironmentObject var userVm: UserViewModel
    let size: CGSize = CGSize(width: (UIScreen.main.bounds.width / 3) - 26, height: ((UIScreen.main.bounds.width / 3) - 26) * 1.5)
    
    var body: some View {
        VStack (alignment: .leading, spacing: 20) {
            HStack{
                Text("Events")
                    .font(.body)
                    .fontWeight(.bold)
                
                if posts.count > 0 {
                    Text("\(formatBigNumbers(Int(count)))")
                        .foregroundStyle(.gray)
                }
                
                Spacer()
                
                if posts.count > 0 {
                    NavigationLink(value: SelectionPath.allUserEvents(userID: userID)){
                        Text("View All")
                            .fontWeight(.semibold)
                    }
                }
                        
                
            }
            .padding(.horizontal)

            
            if posts.count > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack{
                        ForEach(posts.indices, id: \.self){ index in
//                            if posts[index].status == .HAS_ENDED {
//                                NavigationLink(value: SelectionPath.completedEventDetails(post: posts[index])){
//                                    EventComponent(userID: userID, post: posts[index])
//                                }
//                            } else {
                                NavigationLink(value: SelectionPath.eventDetails(posts[index])){
                                    EventComponent(userID: userID, post: posts[index])
                                }
//                            }
                        }
                    }
                    .padding(.horizontal)
                    
                }
            } else if let currentUser = userVm.currentUser, currentUser.id == userID {
                ZStack{
                    ZStack(alignment: .bottom){
                        HStack{
                            Group{
                                Rectangle()

                                Rectangle()

                                Rectangle()

                            }
                            .foregroundStyle(.blackAndWhite)
                            .frame(size)
                            .cornerRadius(20)
                            .opacity(0.2)
                        }
                        
                        LinearGradient(colors: [.base, .clear], startPoint: .bottom, endPoint: .top)
                            .frame(height: 3 * size.height/4)
                    }
                    VStack(alignment: .center, spacing: 10){
                        Image(systemName: "calendar.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        
                        Text("No events")
                            .fontWeight(.semibold)
                            .padding(.bottom)
                        
                        Button{
                            createEvent = true
                        } label:{
                            Text("Create Event")
                                .font(.subheadline)
                                .foregroundStyle(Color("base"))
                                .fontWeight(.semibold)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 13)
                                .background{Color("blackAndWhite")}
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
            }

        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(.vertical)
        .background(.bar)
        .cornerRadius(10)
    }
}



struct EventTab_Previews: PreviewProvider {
    static var previews: some View {
        EventTab(userID: "", posts: .constant([MockPost]), createEvent: .constant(false), count: .constant(0))
            .environmentObject(UserViewModel())

    }
}
