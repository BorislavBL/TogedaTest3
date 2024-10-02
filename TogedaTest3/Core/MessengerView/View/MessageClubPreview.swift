//
//  MessageClubPreview.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 24.07.24.
//

import SwiftUI
import Kingfisher
import WrappingHStack

struct MessageClubPreview: View {
    let clubID: String
    @State var club: Components.Schemas.ClubDto?
    var size: CGSize = .init(width: 180, height: 300)
    @State var Init: Bool = true
    
    var body: some View {
        VStack(alignment: .leading){
            if let club = club {
                NavigationLink(value: SelectionPath.club(club)) {
                    VStack(alignment: .leading){
                        ZStack(alignment: .bottom) {
                            KFImage(URL(string: club.images[0]))
                                .resizable()
                                .scaledToFill()
                                .frame(size)
                                .clipped()
                            
                            LinearGradient(gradient: Gradient(colors: [.black.opacity(0), .black.opacity(0), .black]), startPoint: .top, endPoint: .bottom)
                                .opacity(0.95)
                            
                            VStack(alignment: .leading){
                                if club.currentUserRole == .ADMIN {
                                    Text("Admin")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("light-gray"))
                                        .padding(.bottom, 2)
                                }
                                
                                Text(club.title)
                                    .font(.footnote)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                    .padding(.bottom, 5)
                                
                                WrappingHStack(alignment: .leading, verticalSpacing: 5){
                                    
                                    HStack{
                                        Image(systemName: "eye")
                                            .font(.caption)
                                            .foregroundColor(Color("light-gray"))
                                        if club.askToJoin {
                                            Text("Ask to join")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color("light-gray"))
                                        } else {
                                            Text(club.accessibility.rawValue.capitalized)
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color("light-gray"))
                                        }
                                    }
                                    
                                    HStack{
                                        Image(systemName: "person.2.fill")
                                            .font(.caption)
                                            .foregroundColor(Color("light-gray"))
                                        
                                        Text("\(club.membersCount)")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color("light-gray"))
                                    }
                                    
                                }
                                .padding(.bottom, 2)

                                
                                HStack(alignment: .center){
                                    
                                    Image(systemName: "location")
                                        .font(.caption)
                                        .foregroundColor(Color("light-gray"))
                                    
                                    Text(club.location.name)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("light-gray"))
                                        .multilineTextAlignment(.leading)
                                    
                                }
                            }
                            
                            .padding(.horizontal, 12)
                            .padding(.vertical)
                            .frame(maxWidth: size.width, maxHeight: size.height, alignment: .bottomLeading)
                 
                        }
                        .frame(size)
                        .cornerRadius(20)
                    }
                }
            } else {
                ProgressView()
                    .frame(size)
            }
        }
        .frame(width: size.width)
        .background(Color("SecondaryBackground"))
        .cornerRadius(20)
        .onAppear(){
            Task{
                if Init{
                    if let response =  try await APIClient.shared.getClub(clubID: clubID) {
                        self.club = response
                        self.Init = false
                    }
                }
            }
        }
        
    }
}


#Preview {
    MessageClubPreview(clubID: "")
}
