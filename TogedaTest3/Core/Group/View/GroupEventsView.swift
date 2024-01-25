//
//  GroupEventsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.01.24.
//

import SwiftUI

struct GroupEventsView: View {
    @ObservedObject var groupVM: GroupViewModel
    
    var body: some View {
        VStack (alignment: .leading, spacing: 20) {
            HStack{
                Text("Events")
                    .font(.body)
                    .fontWeight(.bold)
                
                if groupVM.club.events.count > 0 {
                    Text("\(groupVM.club.events.count)")
                        .foregroundStyle(.gray)
                }
                
                Spacer()
                
                
                NavigationLink(destination: AllGroupEventsView(posts: groupVM.club.events)){
                    Text("View All")
                        .fontWeight(.semibold)
                }
                
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack{
                    ForEach(groupVM.club.events.indices, id: \.self){ index in
                        if groupVM.club.events[index].hasEnded {
                            NavigationLink(destination: CompletedEventView(postID: posts[index].id)){
                                GroupEventComponent(post: posts[index])
                            }
                        } else {
                            NavigationLink(destination: EventView(postID: posts[index].id)){
                                GroupEventComponent(post: posts[index])
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

#Preview {
    GroupEventsView(groupVM: GroupViewModel())
}
