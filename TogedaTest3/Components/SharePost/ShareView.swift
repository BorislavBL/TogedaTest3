//
//  SharePostView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 4.12.23.
//

import SwiftUI
import WrappingHStack

struct ShareView: View {
    @Environment(\.dismiss) var dismiss
    @State var searchText: String = ""
    let size: ImageSize = .small
    @State var searchUserResults: [MiniUser] = MiniUser.MOCK_MINIUSERS
    @State var selectedUsers: [MiniUser] = []
    @State var showCancelButton: Bool = false
    
    let testLink = URL(string: "https://www.linkedin.com/in/borislav-lorinkov-724300232/")!
    
    var body: some View {
        VStack {
            HStack(spacing: 16){
                CustomSearchBar(searchText: $searchText, showCancelButton: $showCancelButton)
                    
                
                if !showCancelButton {
                    ShareLink("", item: testLink)
                }
            }
            .padding()
            
            ScrollView {
                if selectedUsers.count > 0{
                    ScrollView{
                        WrappingHStack(alignment: .topLeading){
                            ForEach(selectedUsers, id: \.id) { user in
                                ParticipantsChatTags(user: user){
                                    selectedUsers.removeAll(where: { $0 == user })
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxHeight: 100)
                }
                
                LazyVStack {
                    ForEach(searchUserResults) { user in
                        VStack {
                            Button{
                                if selectedUsers.contains(user) {
                                    selectedUsers.removeAll(where: { $0 == user })
                                } else {
                                    selectedUsers.append(user)
                                }
                            } label:{
                                HStack {
                                    if selectedUsers.contains(user){
                                        Image(systemName: "checkmark.circle.fill")
                                            .imageScale(.large)
                                            .foregroundStyle(.blue)
                                    } else {
                                        Image(systemName: "circle")
                                            .imageScale(.large)
                                            .foregroundStyle(.gray)
                                    }
                                    
                                    Image(user.profileImageUrl[0])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: size.dimension, height: size.dimension)
                                        .clipShape(Circle())
                                    
                                    Text(user.fullName)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                }
                            }
                            
                            Divider()
                                .padding(.leading, 40)
                        }
                        .padding(.leading)
                    }
                }
            }
            .onChange(of: searchText){
                if !searchText.isEmpty {
                    searchUserResults = MiniUser.MOCK_MINIUSERS.filter{result in
                        result.fullName.lowercased().contains(searchText.lowercased())
                    }
                } else {
                    searchUserResults = MiniUser.MOCK_MINIUSERS
                }
            }
            
            if selectedUsers.count > 0{
                VStack{
                    Button{}  label: {
                        Text("Send")
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .fontWeight(.semibold)
                        
                    }
                    .cornerRadius(10)
                    .padding(.top)
                }
                .padding(.horizontal)
            }
            

        }
    }
}

struct ReceiverTags: View {
    var user: MiniUser
    let size: ImageSize = .xxSmall
    @State var clicked = false
    var action: () -> Void
    var body: some View {
        if clicked {
            Button{action()} label:{
                HStack{
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                    
                    
                    Text(user.fullName)
                        .font(.subheadline)
                    
                }
                .frame(height: size.dimension)
                .padding(.horizontal, 8)
                .background(Color(.tertiarySystemFill))
                .clipShape(Capsule())
            }
        } else {
            Button { clicked = true } label:{
                HStack{
                    Image(user.profileImageUrl[0])
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(Circle())
                    
                    Text(user.fullName)
                        .font(.subheadline)
                        .padding(.trailing, 8)
                }
                .background(Color(.tertiarySystemFill))
                .clipShape(Capsule())
            }
        }
        
    }
}

#Preview {
    ShareView()
}
