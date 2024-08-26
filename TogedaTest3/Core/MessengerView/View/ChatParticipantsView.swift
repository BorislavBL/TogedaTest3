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
                    }
            }
            .padding(.horizontal)
            
        }
        .onAppear(){
            Task{
                do{
                    if Init {
                        if let response = try await APIClient.shared.getChatParticipants(chatId: chatId) {
                            self.participants = response
                            Init = false
                        }

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
