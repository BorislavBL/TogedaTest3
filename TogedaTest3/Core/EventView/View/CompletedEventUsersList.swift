//
//  CompletedEventUsersList.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.11.23.
//

import SwiftUI

struct CompletedEventUsersList: View {
    @Environment(\.dismiss) private var dismiss
    @State var users: [Components.Schemas.MiniUser] = []
    @State var selectedUserId: String = ""
    @State var showOptions: Bool = false
    @State var selectedOption: String?
    let size: ImageSize = .medium
    var body: some View {
        ScrollView{
            LazyVStack(alignment:.leading){
                ForEach(users, id:\.id) { user in
                    HStack{
                        NavigationLink(value: SelectionPath.profile(MockMiniUser)){
                            Image(user.profilePhotos[0])
                                .resizable()
                                .scaledToFill()
                                .frame(width: size.dimension, height: size.dimension)
                                .clipShape(Circle())
                            
                            
                            Text("\(user.firstName) \(user.lastName)")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                        
                        Button {
                            showOptions = true
                        } label: {
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90))
                        }
                    }
                    .padding(.vertical, 5)
                    
                }
                
            }
            .padding(.horizontal)
            
        }
        .sheet(isPresented: $showOptions, content: {
            List {
                Button("Share via") {
                    selectedOption = "Share"
                }
                
                Button("Block") {
                    selectedOption = "Block"
                }
                
                Button("Report") {
                    selectedOption = "Report"
                }
            }
            .presentationDetents([.fraction(0.4)])
            .presentationDragIndicator(.visible)
        })
        .navigationTitle("Participants")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
    }
    
}

#Preview {
    CompletedEventUsersList(users: [])
}
