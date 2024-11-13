//
//  ClubsTab.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct ClubsTab: View {
    var userID: String
    var count: Int64
    @Binding var createClub: Bool
    
    @Binding var clubs: [Components.Schemas.ClubDto]
    @EnvironmentObject var userVm: UserViewModel
    let size: CGSize = CGSize(width: (UIScreen.main.bounds.width / 3) - 26, height: ((UIScreen.main.bounds.width / 3) - 26) * 1.5)

    
    var body: some View {
        VStack (alignment: .leading, spacing: 20) {
            HStack{
                Text("Clubs")
                    .font(.body)
                    .fontWeight(.bold)
                
                if clubs.count > 0 {
                    Text("\(formatBigNumbers(Int(count)))")
                        .foregroundStyle(.gray)
                }
                
                
                Spacer()
                
                
                if clubs.count > 0 {
                    NavigationLink(value: SelectionPath.allUserGroups(userID: userID)){
                        Text("View All")
                            .fontWeight(.semibold)
                        
                    }
                }
                
            }
            .padding(.horizontal)
            
            if clubs.count > 0 {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack{
                        ForEach(clubs, id: \.id){ club in
                            NavigationLink(value: SelectionPath.club(club)){
                                GroupComponent(userID: userID, club: club)
                            }
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
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        
                        Text("No Clubs")
                            .fontWeight(.semibold)
                            .padding(.bottom)
                        
                        Button{
                            createClub = true
                        } label:{
                            Text("Create Club")
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


struct ClubsTab_Previews: PreviewProvider {
    static var previews: some View {
        ClubsTab(userID: "", count: 0, createClub: .constant(false), clubs: .constant([MockClub]))
            .environmentObject(UserViewModel())

    }
}

