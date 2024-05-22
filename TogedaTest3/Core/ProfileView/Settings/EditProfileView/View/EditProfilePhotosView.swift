//
//  EditProfilePhotosView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 19.12.23.
//

import SwiftUI
import Kingfisher

struct EditProfilePhotosView: View {
    @ObservedObject var editProfileVM: EditProfileViewModel
    private let imageDimension: CGFloat = (UIScreen.main.bounds.width / 3) - 16
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Grid {
            GridRow {
                ForEach(0..<3, id: \.self){ index in
                    ZStack{
                        if let image = editProfileVM.selectedImages[index]{
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width:imageDimension, height: imageDimension * 1.3)
                                .cornerRadius(10)
                                .clipped()
                        } else if index < editProfileVM.editUser.profilePhotos.count {
                            KFImage(URL(string: editProfileVM.editUser.profilePhotos[index]))
                                .resizable()
                                .scaledToFill()
                                .frame(width:imageDimension, height: imageDimension * 1.3)
                                .cornerRadius(10)
                                .clipped()
                        } else {
                            Color("main-secondary-color")
                                .frame(width:imageDimension, height: imageDimension * 1.3)
                                .cornerRadius(10)
                            
                            Image(systemName: "plus.circle")
                                .foregroundStyle(Color("SelectedFilter"))
                                .imageScale(.large)
                        }
                    }
                    .onTapGesture {
                        editProfileVM.selectedImageIndex = index
                        editProfileVM.showPhotosPicker = true
                    }
                }
            }
            .padding(.bottom, 2)
            GridRow {
                ForEach(3..<6, id: \.self){ index in
                    ZStack{
                        if let image = editProfileVM.selectedImages[index]{
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width:imageDimension, height: imageDimension * 1.3)
                                .cornerRadius(10)
                                .clipped()
                        } else if index < editProfileVM.editUser.profilePhotos.count {
                            KFImage(URL(string: editProfileVM.editUser.profilePhotos[index]))
                                .resizable()
                                .scaledToFill()
                                .frame(width:imageDimension, height: imageDimension * 1.3)
                                .cornerRadius(10)
                                .clipped()
                        } else {
                            Color("main-secondary-color")
                                .frame(width:imageDimension, height: imageDimension * 1.3)
                                .cornerRadius(10)
                            
                            Image(systemName: "plus.circle")
                                .foregroundStyle(Color("SelectedFilter"))
                                .imageScale(.large)
                        }
                    }
                    .onTapGesture {
                        editProfileVM.selectedImageIndex = index
                        editProfileVM.showPhotosPicker = true
                    }
                }
            }
        }
        .photosPicker(isPresented: $editProfileVM.showPhotosPicker, selection: $editProfileVM.imageselection, matching: .images)
        .fullScreenCover(isPresented: $editProfileVM.showCropView, content: {
            CropPhotoView(selectedImage:editProfileVM.selectedImage, finalImage: $editProfileVM.selectedImages[editProfileVM.selectedImageIndex ?? 0], crop: .custom(CGSize(width: 300, height: 500)))
        })
        .frame(maxHeight: .infinity, alignment: .top )
    }
    
}

#Preview {
    EditProfilePhotosView(editProfileVM: EditProfileViewModel())
}
