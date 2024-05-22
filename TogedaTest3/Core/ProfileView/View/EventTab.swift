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
    @State var posts: [Components.Schemas.PostResponseDto] = []
    @Binding var createEvent: Bool
    
    var body: some View {
        VStack (alignment: .leading, spacing: 20) {
            HStack{
                Text("Events")
                    .font(.body)
                    .fontWeight(.bold)
                
                if posts.count > 0 {
                    Text("\(posts.count)")
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
                            if posts[index].hasEnded {
                                //                            NavigationLink(value: SelectionPath.completedEventDetails(posts[index])){
                                EventComponent(userID: userID, post: posts[index])
                                //                            }
                            } else {
                                NavigationLink(value: SelectionPath.eventDetails(posts[index])){
                                    EventComponent(userID: userID, post: posts[index])
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                }
            } else {
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
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(.vertical)
        .background(.bar)
        .cornerRadius(10)
        .onAppear(){
            Task{
                if let response = try await APIClient.shared.getUserEvents(userId: userID, page: 0, size: 15) {
                    posts = response.data
                }
            }
        }
    }
}



struct EventTab_Previews: PreviewProvider {
    static var previews: some View {
        EventTab(userID: "", createEvent: .constant(false))

    }
}
