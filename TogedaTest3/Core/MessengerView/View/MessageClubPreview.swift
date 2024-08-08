//
//  MessageClubPreview.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 24.07.24.
//

import SwiftUI
import Kingfisher

struct MessageClubPreview: View {
    let clubID: String
    @State var club: Components.Schemas.ClubDto?
    
    var body: some View {
        VStack(alignment: .leading){
            if let club = club {
                NavigationLink(value: SelectionPath.club(club)) {
                    VStack(alignment: .leading){
                        KFImage(URL(string: club.images[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width - 120, height: 220)
                            .clipped()
                        
                        HStack(spacing: 0){
                            Text(club.title)
                                .font(.callout)
                                .bold()
                                .lineLimit(2)
                            
                            Spacer(minLength: 10)
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                        .padding()
                    }
                }
            } else {
                ProgressView()
                .frame(width: UIScreen.main.bounds.width - 120, height: 250)
            }
        }
        .frame(width: UIScreen.main.bounds.width - 120)
        .background(Color("SecondaryBackground"))
        .cornerRadius(10)
        .onAppear(){
            Task{
                self.club = try await APIClient.shared.getClub(clubID: clubID)
            }
        }
        
    }
}


#Preview {
    MessageClubPreview(clubID: "")
}
