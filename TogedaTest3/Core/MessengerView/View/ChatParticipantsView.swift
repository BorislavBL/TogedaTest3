//
//  ChatParticipantsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 26.08.24.
//

import SwiftUI
import Kingfisher

struct ChatParticipantsView: View {
    @Environment(\.dismiss) private var dismiss
    let size: ImageSize = .medium
    
    @State var isLoading = false
    @State var showReportSheet = false
    @State var Init: Bool = true
    var chatId: String
    
    @State var lastPage: Bool = true
    @State var page: Int32 = 0
    @State var pageSize: Int32 = 15
    @State var participants: [Components.Schemas.MiniUser] = []
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment:.leading){
                ForEach(participants, id:\.id) { user in
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
                            }
                        }
                        
                        Spacer()
                        
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
                              if let response = try await APIClient.shared.getChatParticipants(chatId: chatId, page: page, size: pageSize) {
                                    self.participants += response.data
                                    self.lastPage = response.lastPage
                                    self.page += 1
                                }
                                isLoading = false
                                
                            }
                        }
                    }
            }
            .padding(.horizontal)
            
        }
        .refreshable {
            self.participants = []
            self.lastPage = true
            self.page = 0
            
            Task{
                if let response = try await APIClient.shared.getChatParticipants(chatId: chatId, page: page, size: pageSize) {
                    self.participants += response.data
                    self.lastPage = response.lastPage
                    self.page += 1
                }
            }
        }
        .onAppear(){
            Task{
                do{
                    if Init {
                        if let response = try await APIClient.shared.getChatParticipants(chatId: chatId, page: page, size: pageSize) {
                            self.participants += response.data
                            self.lastPage = response.lastPage
                            self.page += 1
                        }
                        
                        Init = false
                    }
                } catch {
                    print("User list error:", error.localizedDescription)
                }
            }
        }
        .background(.bar)
        .navigationTitle("Participants")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
        .swipeBack()

    }
}

#Preview {
    ChatParticipantsView(chatId: "")
}
