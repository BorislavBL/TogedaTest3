//
//  GroupEventsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.01.24.
//

import SwiftUI

struct ClubEventsView: View {
    var club: Components.Schemas.ClubDto
    @ObservedObject var groupVM: ClubViewModel
    
    var body: some View {
        VStack (alignment: .leading, spacing: 20) {
            HStack{
                Text("Events")
                    .font(.body)
                    .fontWeight(.bold)
                
                
                Text("\(formatBigNumbers(Int(groupVM.clubEventsCount)))")
                    .foregroundStyle(.gray)
                
                Spacer()
                
                
                NavigationLink(value: SelectionPath.allClubEventsView(club.id)){
                    Text("View All")
                        .fontWeight(.semibold)
                }
                
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack{
                    ForEach(groupVM.clubEvents, id: \.id){ item in
//                        if item.status == .HAS_ENDED {
//
//                            NavigationLink(value: SelectionPath.completedEventDetails(post: item)){
//                                ClubEventComponent(post: item)
//                            }
//                            
//                        } else {
                            NavigationLink(value: SelectionPath.eventDetails(item)){
                                ClubEventComponent(post: item)
                            }
//                        }
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
    ClubEventsView(club: MockClub, groupVM: ClubViewModel())
}
