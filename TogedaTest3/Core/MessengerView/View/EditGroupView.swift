//
//  EditGroupView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 28.12.24.
//

import SwiftUI
import Kingfisher

struct EditGroupView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var photoPickerVM = PhotoPickerViewModel(s3BucketName: .user, mode: .normal)
    
    @EnvironmentObject var navManager: NavigationManager
    @EnvironmentObject var userVm: UserViewModel
    @EnvironmentObject var chatManager: WebSocketManager
    
    @State var title = ""
    @State var cropImage: UIImage? = nil
    @State var imageURL: String? = nil
    
    @State var chatRoom: Components.Schemas.ChatRoomDto
    
    var body: some View {
        ScrollView{
            VStack(spacing: 16){
                if let image = imageURL {
                    Menu {
                        Button("Change") {
                            photoPickerVM.showPhotosPicker = true
                        }
                        
                        Button("Remove") {
                            imageURL = nil
                            
                        }
                    }label: {
                        KFImage(URL(string: image))
                            .resizable()
                            .scaledToFill()
                            .frame(height: 400)
                            .frame(minWidth: 0)
                            .cornerRadius(10)
                    }
                    
                } else if let image = cropImage {
                    Button{
                        photoPickerVM.showPhotosPicker = true
                    } label: {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 400)
                            .frame(minWidth: 0)
                            .cornerRadius(10)
                    }
                } else {
                    Button{
                        photoPickerVM.showPhotosPicker = true
                    } label: {
                        ZStack {
                            Rectangle()
                                .foregroundStyle(Color(.tertiarySystemFill))
                                .frame(height: 400)
                                .frame(minWidth: 0)
                                .cornerRadius(10)
                            
                            Image(systemName: "photo.on.rectangle")
                                .imageScale(.large)
                        }
                    }
                }
               
                TextField("Group Title", text: $title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding()
                    .background(Color(.tertiarySystemFill))
                    .cornerRadius(10)
                
            }
            .padding()
        }
        .sheet(isPresented: $photoPickerVM.showPhotosPicker) {
            PhotoPicker(selectedImage: $photoPickerVM.selectedImage, showCropView: $photoPickerVM.showCropView)
        }
        .sheet(isPresented: $photoPickerVM.showCropView) {
            if let imageToCrop = photoPickerVM.selectedImage {
                CropView(image: imageToCrop, cropSize: CGSize(width: 800, height: 800)) { croppedImage in
                    cropImage = croppedImage
                    photoPickerVM.showCropView = false
                } onCancel: {
                    photoPickerVM.showCropView = false
                }
                .transition(.opacity)
                .interactiveDismissDisabled()
            }
        }
        .navigationTitle("Edit Group")
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
                if title != chatRoom.title || imageURL != chatRoom.image{
                    Button("Done") {
                        done()
                    }
                } else {
                    Text("Done")
                        .foregroundStyle(.gray)
                }
            }
        }
        .swipeBack()
        .onAppear() {
            title = chatRoom.title ?? ""
            imageURL = chatRoom.image
        }
    }
    
    func done() {
        Task {
            if let _cropImage = cropImage {
                imageURL = await photoPickerVM.uploadImage(uiImage: _cropImage)
            }
            if let response = try await APIClient.shared.patchGroupChat(image: imageURL, title: title.isEmpty ? nil : trimAndLimitWhitespace(title), chatId: chatRoom.id) {
                if let chatRoom = try await APIClient.shared.getChat(chatId: chatRoom.id) {
                    DispatchQueue.main.async {
                        if let index = chatManager.allChatRooms.firstIndex(where: {$0.id == chatRoom.id}) {
                            chatManager.allChatRooms[index] = chatRoom
                            navManager.selectionPath = []
                        }
                        
                    }
                }
            }
                
            
        }
    }
}


#Preview {
    EditGroupView(chatRoom: mockChatRoom)
        .environmentObject(NavigationManager())
        .environmentObject(UserViewModel())
        .environmentObject(WebSocketManager())
}
