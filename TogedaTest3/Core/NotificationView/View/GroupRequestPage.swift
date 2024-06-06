//
//  GroupRequestPage.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 22.01.24.
//

import SwiftUI
import Kingfisher

struct GroupRequestPage: View {
    let size: ImageSize = .medium
    var club: Components.Schemas.ClubDto = MockClub
    @EnvironmentObject var postsVM: PostsViewModel
    
    var body: some View {
            VStack {
                NavigationLink(value: SelectionPath.club(club)){
                    HStack(alignment:.top){
                        KFImage(URL(string: club.images[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .cornerRadius(10)
                            .clipped()
                    }
                    
                    VStack(alignment: .leading, spacing: 5){
                        Text(club.title)
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        Text("Someone wants to join your club.")
                            .font(.footnote) +
                        
                        Text(" 1 min ago")
                            .foregroundStyle(.gray)
                            .font(.footnote)
                        
                        
                    }
                    .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                    
                }
                
            }
    }
}

#Preview {
    GroupRequestPage()
}
