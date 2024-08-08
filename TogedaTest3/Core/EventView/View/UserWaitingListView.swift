//
//  UserWaitingListView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 11.06.24.
//

import SwiftUI
import Kingfisher

struct UserWaitingListView: View {
    @Environment(\.dismiss) private var dismiss
    let size: ImageSize = .medium
    
    @State var isLoading = false
    
    var post: Components.Schemas.PostResponseDto
    @State var Init: Bool = true
    
//    @State var waitingList: [Components.Schemas.MiniUser] = []
//    @State var page: Int32 = 0
//    @State var pageSize: Int32 = 15
//    @State var lastPage: Bool = true
    
    @StateObject var eventVM = EventViewModel()
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment:.leading){                
                ForEach(eventVM.waitingList, id:\.id) { user in
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

                                Image(systemName: "chevron.right")
                                
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
                        if !eventVM.waitingListLastPage {
                            isLoading = true
                            
                            Task{
                                try await eventVM.fetchWaitingList(id: post.id)
                                isLoading = false
                                
                            }
                        }
                    }
            }
            .padding(.horizontal)
            
        }
        .onAppear(){
            Task{
                do{
                    if Init {
                        eventVM.waitingList = []
                        eventVM.waitingListPage = 0
                        try await eventVM.fetchWaitingList(id: post.id)
                        Init = false
                        
                    }
                } catch {
                    print("User list error:", error.localizedDescription)
                }
            }
        }
        .background(.bar)
        .navigationTitle("Waiting List")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
        .swipeBack()
    }
}

#Preview {
    UserWaitingListView(post: MockPost)
}
