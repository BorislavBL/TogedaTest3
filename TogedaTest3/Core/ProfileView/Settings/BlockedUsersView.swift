//
//  BlockedUsersView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.11.24.
//

import SwiftUI
import Kingfisher

struct BlockedUsersView: View {
    private let size: ImageSize = .medium
    @Environment(\.dismiss) private var dismiss
    
    @State var isLoading = false
    
    @State var blockedUsersList: [Components.Schemas.MiniUser] = []
    @State var blockedUsersPage: Int32 = 0
    @State var blockedUsersSize: Int32 = 15
    @State var Init: Bool = true
    @State var lastPage = true
    
    @State var loadingState: LoadingCases = .loading
    
    var body: some View {
        ScrollView{
            LazyVStack(spacing: 16){
                if blockedUsersList.count > 0 && loadingState == .loaded{
                    ForEach(blockedUsersList, id:\.id) { user in
                        HStack{
                            NavigationLink(value: SelectionPath.profile(user)){
                                HStack{
                                    KFImage(URL(string: user.profilePhotos[0]))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: size.dimension, height: size.dimension)
                                        .clipShape(Circle())
                                    
                                    Text("\(user.firstName) \(user.lastName)")
                                        .fontWeight(.semibold)
                                    
                                    
                                    Spacer()
                                    
                                    Button{
                                        Task{
                                            if try await APIClient.shared.unBlockUser(userId: user.id) != nil {
                                                if let index = blockedUsersList.firstIndex(where: { $0.id == user.id }) {
                                                    blockedUsersList.remove(at: index)
                                                }
                                            }
                                        }
                                    } label:{
                                        Text("Unblock")
                                            .normalTagTextStyle()
                                            .normalTagCapsuleStyle()
                                    }
                                }
                                
                                
                            }
                            
                            
                            
                        }
                        .padding(.vertical, 5)
                    }
                    
                    if isLoading{
                        ProgressView()
                    }
                    
                    Rectangle()
                        .frame(width: 0, height: 0)
                        .onAppear {
                            if !lastPage {
                                isLoading = true
                                
                                Task{
                                    if let response = try await APIClient.shared.blockedUsers(page: blockedUsersPage, size: blockedUsersSize){
                                        let newResponse = response.data
                                        let existingResponseIDs = Set(self.blockedUsersList.suffix(30).map { $0.id })
                                        let uniqueNewResponse = newResponse.filter { !existingResponseIDs.contains($0.id) }
                                        
                                        blockedUsersList += uniqueNewResponse
                                        blockedUsersPage += 1
                                        lastPage = response.lastPage
                                    }
                                    isLoading = false
                                    
                                }
                            }
                        }
                } else if loadingState == .noResults {
                    VStack(spacing: 15){
                        Text("😥")
                            .font(.custom("image", fixedSize: 120))
                        
                        Text("No blocked users yet! Maybe everyone's just really nice... for now.")
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
        .onAppear(){
            Task{
                do{
                    if Init {
                        if let response = try await APIClient.shared.blockedUsers(page: blockedUsersPage, size: blockedUsersSize){
                            blockedUsersList = response.data
                            blockedUsersPage += 1
                            lastPage = response.lastPage
                            loadingState = .loaded
                            Init = false
                            if response.lastPage && blockedUsersList.count == 0{
                                loadingState = .noResults
                            }
                        } else {
                            loadingState = .noResults
                            Init = false
                        }
                        
                    }
                    
                } catch {
                    print("User list error:", error.localizedDescription)
                }
            }
        }
        .swipeBack()
        .navigationTitle("Blocked Users")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
        .padding(.top)
        .padding(.horizontal)
        
    }
}

#Preview {
    BlockedUsersView()
}
