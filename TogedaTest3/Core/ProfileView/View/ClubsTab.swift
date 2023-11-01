//
//  ClubsTab.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct ClubsTab: View {
    @State var selectedFilter: String = "All"
    
    private let gridItems: [GridItem] = [
        .init(.flexible(), spacing: 2),
        .init(.flexible(), spacing: 2),
        .init(.flexible(), spacing: 2),
    ]
    @State var posts: [Post] = Post.MOCK_POSTS
    var body: some View {
        VStack (alignment: .leading, spacing: 20) {
            Text("Clubs")
                .font(.body)
                .fontWeight(.bold)
            
            HStack(alignment: .center, spacing: 5) {
                
                ForEach(["All", "Owner", "Member"], id:\.self) {filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        if selectedFilter == filter {
                            Text(filter)
                                .selectedTagTextStyle()
                                .selectedTagCapsuleStyle()
                        } else {
                            Text(filter)
                                .normalTagTextStyle()
                                .normalTagCapsuleStyle()
                        }
                    }
                }
                
            }

            
            LazyVGrid(columns: gridItems, spacing: 10) {
                ForEach(0..<6, id: \.self){ index in
                    EventComponent(post: posts[index])
                }
            }
            
            NavigationLink(destination: UserTabViews(title: "Clubs", filters: ["All", "Owner", "Member"])) {
                Text("View All")
                    .normalTagTextStyle()
                    .frame(maxWidth: .infinity)
                    .normalTagRectangleStyle()
                    
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding()
        .background(.bar)
        .cornerRadius(10)
    }
}

struct ClubComponent: View {
    
    private let imageDimension: CGFloat = (UIScreen.main.bounds.width / 3) - 18
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image("event_1")
                .resizable()
                .scaledToFill()
                .frame(width: imageDimension, height: imageDimension + imageDimension * 0.3)
                .clipped()
            
            VStack{
                Text("Hiking in the mountain")
                    .font(.footnote)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: imageDimension)
            .frame(height: imageDimension * 0.4)
            .background(Color(.black).opacity(0.3))
        }
        .cornerRadius(20)
    }
}
struct ClubsTab_Previews: PreviewProvider {
    static var previews: some View {
        ClubsTab()
    }
}

