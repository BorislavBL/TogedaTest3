//
//  NewGroupChatCreateView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 29.11.23.
//

import SwiftUI

struct NewGroupChatCreateView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var newChatVM: NewChatViewModel
    var body: some View {
        ScrollView{
            VStack(spacing: 16){
                if let image = newChatVM.groupImage {
                    Button{
                        newChatVM.showPhotosPicker = true
                    } label: {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .frame(minWidth: 0)
                            .cornerRadius(10)
                    }

                } else {
                    Button{
                        newChatVM.showPhotosPicker = true
                    } label: {
                        ZStack {
                            Rectangle()
                                .foregroundStyle(Color(.tertiarySystemFill))
                                .frame(height: 200)
                                .frame(minWidth: 0)
                                .cornerRadius(10)
                            
                            Image(systemName: "photo.on.rectangle")
                                .imageScale(.large)
                        }
                    }
                }
               
                TextField("Group Name", text: $newChatVM.groupName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding()
                    .background(Color(.tertiarySystemFill))
                    .cornerRadius(10)
                
            }
            .padding()
        }
        .photosPicker(isPresented: $newChatVM.showPhotosPicker, selection: $newChatVM.selectedItem)
        .navigationTitle("New Group")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button{
                    dismiss()
                } label:{
                    Image(systemName: "chevron.left")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if !newChatVM.groupName.isEmpty {
                    Button("Create") {
                        
                    }
                } else {
                    Text("Create")
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}

#Preview {
    NewGroupChatCreateView(newChatVM: NewChatViewModel())
}
