//
//  PhotoPickerView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 16.10.23.
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @ObservedObject var photoPickerVM: PhotoPickerViewModel
    private let imageDimension: CGFloat = (UIScreen.main.bounds.width / 3) - 18
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment:.leading, spacing: 50){
                Text("Add Photos")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
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
                                    Color("secondaryColor")
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
                                    Color("secondaryColor")
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
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .imageScale(.medium)
                .padding(.all, 8)
                .background(Color("secondaryColor"))
                .clipShape(Circle())
        })
        .padding(.vertical)
        .frame(maxHeight: .infinity, alignment: .top )
    }
    
}

#Preview {
    PhotoPickerView(photoPickerVM: PhotoPickerViewModel())
}
