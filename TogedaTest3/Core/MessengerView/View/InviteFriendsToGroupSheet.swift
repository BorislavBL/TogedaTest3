//
//  InviteFriendsToGroupSheet.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 27.12.24.
//

import SwiftUI
import Kingfisher
import WrappingHStack

struct InviteFriendsToGroupSheet: View {
    var chatId: String
    @State var searchedFriends: [Components.Schemas.MiniUser] = []
    @State var selectedFriends: [Components.Schemas.MiniUser] = []
    @State var showCancelButton: Bool = false
    
    @State var friends: [Components.Schemas.MiniUser] = []
    @State var lastPage: Bool = true
    @State var page: Int32 = 0
    @State var listSize: Int32 = 15
    @State var isLoading = false
    @State var loadingState: LoadingCases = .loading
    @Environment(\.dismiss) var dismiss
    let size: ImageSize = .small
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        NavigationStack{
            VStack {
                ScrollView {
                    if selectedFriends.count > 0 {
                        ScrollView{
                            WrappingHStack(alignment: .topLeading){
                                ForEach(selectedFriends, id: \.id) { user in
                                    FriendsTags(user: user) {
                                        selectedFriends.removeAll(where: { $0 == user })
                                    }
                                    
                                }
                            }
                        }
                        .padding()
                        .frame(maxHeight: 100)
                    }
                    
                    LazyVStack {
                        if friends.count > 0{
                            ForEach(friends, id: \.id) { _user in
                                VStack {
                                    Button{
                                        if selectedFriends.contains(_user) {
                                            selectedFriends.removeAll(where: { $0 == _user })
                                        } else {
                                            selectedFriends.append(_user)
                                        }
                                    } label:{
                                        friendsLabel(user: _user)
                                    }
                                    
                                    Divider()
                                        .padding(.leading, 40)
                                }
                                .padding(.leading)
                            }
                            
                            Rectangle()
                                .frame(width: 0, height: 0)
                                .onAppear {
                                    if !lastPage{
                                        isLoading = true
                                        Task{
                                            try await fetchList()
                                            isLoading = false
                                            
                                        }
                                    }
                                    
                                }
                        } else if loadingState == .noResults {
                            VStack(spacing: 15){
                                Text("👥")
                                    .font(.custom("image", fixedSize: 120))
                                
                                Text("No friends yet! Start connecting by joining events and clubs or sending a friend request to get the ball rolling!")
                                    .font(.body)
                                    .foregroundStyle(.gray)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom)
                                
                            }
                            .padding(.all)
                            .frame(maxHeight: .infinity, alignment: .center)
                        }
                        
                    }
                }
                
                if friends.count > 0 {
                    VStack{
                        Button{
                            Task{
                                for friend in selectedFriends {
                                    do {
                                        try await APIClient.shared.addFriendToChatRoomParticipants(chatId: chatId, userId: friend.id)
                                    } catch {
                                        print("Failed to add \(friend.firstName) \(friend.lastName): \(error)")
                                    }
                                }
                                dismiss()
                            }
                        } label: {
                            Text("Add")
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
            .padding(.top, 20)
        }
        .onAppear(){
            Task{
                try await fetchList()
            }
        }
    }
    
    @ViewBuilder
    func friendsLabel(user: Components.Schemas.MiniUser) -> some View {
        HStack {
            if selectedFriends.contains(where: {$0.id == user.id}){
                Image(systemName: "checkmark.circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(.blue)
            } else {
                Image(systemName: "circle")
                    .imageScale(.large)
                    .foregroundStyle(.gray)
            }

            KFImage(URL(string: user.profilePhotos[0]))
                .resizable()
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
           
            
            
            Text("\(user.firstName) \(user.lastName)")
                .lineLimit(1)
                .font(.subheadline)
         
                    
                    
            Spacer(minLength: 10)
                
            
            
            
            Spacer()
        }
    }
    
    func fetchList() async throws {
        if let user = userVM.currentUser {
            if let response = try await APIClient.shared.getFriendList(userId: user.id, page: self.page, size: self.listSize) {
                DispatchQueue.main.async {
                    let newResponse = response.data
                    let existingResponseIDs = Set(self.friends.suffix(30).map { $0.id })
                    let uniqueNewResponse = newResponse.filter { !existingResponseIDs.contains($0.user.id) }
                    
                    let uniqueUsers = uniqueNewResponse.map({$0.user})
                    
                    self.friends += uniqueUsers
                    self.page += 1
                    self.lastPage = response.lastPage
                    self.loadingState = .loaded
                    if response.lastPage && self.friends.count == 0{
                        self.loadingState = .noResults
                    }
                    
                    print("unique 1:", uniqueUsers)
                    print("unique 2:", newResponse.count)

                }
            } else {
                DispatchQueue.main.async {
                    self.loadingState = .noResults
                }
            }
        }
    }
    
}


struct FriendsTags: View {
    var user: Components.Schemas.MiniUser
    let size: ImageSize = .xxSmall
    @State var clicked = false
    var action: () -> Void
    var body: some View {
        if clicked {
            Button{action()} label:{
                HStack{
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                    
                    
                    Text("\(user.firstName) \(user.lastName)")
                        .lineLimit(1)
                        .font(.subheadline)

                }
                .frame(height: size.dimension)
                .padding(.horizontal, 8)
                .background(Color(.tertiarySystemFill))
                .clipShape(Capsule())
            }
        } else {
            Button{clicked = true} label:{
                HStack(alignment: .center){
                    
                    KFImage(URL(string: user.profilePhotos[0]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)

                    Text("\(user.firstName) \(user.lastName)")
                        .lineLimit(1)
                        .font(.subheadline)

                }
                .frame(height: size.dimension)
                .padding(.trailing, 8)
                .background(Color(.tertiarySystemFill))
                .clipShape(Capsule())
            }
        }
        
    }
}


#Preview {
    InviteFriendsToGroupSheet(chatId: "")
        .environmentObject(UserViewModel())
}
