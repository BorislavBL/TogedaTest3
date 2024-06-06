//
//  NormalPhotoPickerView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 29.12.23.
//

import SwiftUI
import PhotosUI

struct NormalPhotoPickerView: View {
    @ObservedObject var photoPickerVM: PhotoPickerViewModel
    private let imageDimension: CGFloat = (UIScreen.main.bounds.width / 3) - 16
    @Environment(\.dismiss) private var dismiss
    let message: String
    
    var body: some View {
        ScrollView {
            VStack(alignment:.leading, spacing: 10){
                
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.gray)
                
                Grid {
                    GridRow {
                        ForEach(0..<3, id: \.self){ index in
                            ZStack{
                                if let image = photoPickerVM.selectedImages[index]{
                                    Image(uiImage: image)
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
                                photoPickerVM.selectedImageIndex = index
                                photoPickerVM.showPhotosPicker = true
                            }
                        }
                    }
                    GridRow {
                        ForEach(3..<6, id: \.self){ index in
                            ZStack{
                                if let image = photoPickerVM.selectedImages[index]{
                                    Image(uiImage: image)
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
                                photoPickerVM.selectedImageIndex = index
                                photoPickerVM.showPhotosPicker = true
                            }
                        }
                    }
                }
                
            }
            
        }
        .photosPicker(isPresented: $photoPickerVM.showPhotosPicker, selection: $photoPickerVM.imageselection, matching: .images)
        .fullScreenCover(isPresented: $photoPickerVM.showCropView, content: {
            CropPhotoView(selectedImage:photoPickerVM.selectedImage, finalImage: $photoPickerVM.selectedImages[photoPickerVM.selectedImageIndex ?? 0], crop: .custom(CGSize(width: 300, height: 500)))
        })
        .navigationTitle("Photos")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .imageScale(.medium)
                .padding(.all, 8)
                .background(Color("main-secondary-color"))
                .clipShape(Circle())
        })
        .padding(.vertical)
        .frame(maxHeight: .infinity, alignment: .top )
    }
    
}


#Preview {
    NormalPhotoPickerView(photoPickerVM: PhotoPickerViewModel(s3BucketName: .user, mode: .normal), message: "Select photos related to your activity.")
}
