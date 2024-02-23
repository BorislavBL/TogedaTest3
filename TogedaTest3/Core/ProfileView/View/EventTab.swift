//
//  EventTab.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct EventTab: View {
    var userID: String
    @State var posts: [Post] = Post.MOCK_POSTS
    
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
                
                NavigationLink(value: SelectionPath.allUserEvents(userID: userID, posts: posts)){
                    Text("View All")
                        .fontWeight(.semibold)
                }
                        
                
            }
            .padding(.horizontal)

            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack{
                    ForEach(posts.indices, id: \.self){ index in
                        if posts[index].hasEnded {
                            NavigationLink(value: SelectionPath.completedEventDetails(posts[index])){
                                EventComponent(userID: userID, post: posts[index])
                            }
                        } else {
                            NavigationLink(value: SelectionPath.eventDetails(posts[index])){
                                EventComponent(userID: userID, post: posts[index])
                            }
                        }
                    }
                }
                .padding(.horizontal)
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
        EventTab(userID: User.MOCK_USERS[0].id)

    }
}
