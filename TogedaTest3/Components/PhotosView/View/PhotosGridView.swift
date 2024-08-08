//
//  PhotosGridView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 5.01.24.
//

import SwiftUI
import Kingfisher

struct PhotosGridView: View {
    @Binding var images: [String]
    @ObservedObject var vm: PhotoPickerViewModel
    private let imageDimension: CGFloat = (UIScreen.main.bounds.width / 3) - 16
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Grid {
            GridRow {
                ForEach(0..<3, id: \.self){ index in
                    VStack{
                        if let image = vm.selectedImages[index]{
                            Menu{
                                Button(action: {
                                    vm.selectedImageIndex = index
                                    vm.showPhotosPicker = true
                                }) {
                                    Text("Change Image")
                                    Image(systemName: "photo.fill")
                                }
                                
                                Button(role: .destructive, action: {
                                    vm.selectedImages[index] = nil
                                }) {
                                    Text("Delete")
                                    Image(systemName: "trash.fill")
                                }
                            } label: {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:imageDimension, height: imageDimension * 1.3)
                                    .cornerRadius(10)
                                    .clipped()
                            }
                        } else if index < images.count {
                            Menu{
                                Button(action: {
                                    vm.selectedImageIndex = index
                                    vm.showPhotosPicker = true
                                }) {
                                    Text("Change Image")
                                    Image(systemName: "photo.fill")
                                }
                                
                                Button(role: .destructive, action: {
                                    images.remove(at: index)
                                }) {
                                    Text("Delete")
                                    Image(systemName: "trash.fill")
                                }
                            } label: {
                                KFImage(URL(string: images[index]))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:imageDimension, height: imageDimension * 1.3)
                                    .cornerRadius(10)
                                    .clipped()
                            }
                        } else {
                            ZStack(){
                                Color("main-secondary-color")
                                    .frame(width:imageDimension, height: imageDimension * 1.3)
                                    .cornerRadius(10)
                                
                                Image(systemName: "plus.circle")
                                    .foregroundStyle(Color("SelectedFilter"))
                                    .imageScale(.large)
                            }
                            .onTapGesture {
                                vm.selectedImageIndex = index
                                vm.showPhotosPicker = true
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 2)
            GridRow {
                ForEach(3..<6, id: \.self){ index in
                    VStack{
                        if let image = vm.selectedImages[index]{
                            Menu{
                                Button(action: {
                                    vm.selectedImageIndex = index
                                    vm.showPhotosPicker = true
                                }) {
                                    Text("Change Image")
                                    Image(systemName: "photo.fill")
                                }
                                
                                Button(role: .destructive, action: {
                                    vm.selectedImages[index] = nil
                                }) {
                                    Text("Delete")
                                    Image(systemName: "trash.fill")
                                }
                            } label: {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:imageDimension, height: imageDimension * 1.3)
                                    .cornerRadius(10)
                                    .clipped()
                            }
                        } else if index < images.count {
                            Menu{
                                Button(action: {
                                    vm.selectedImageIndex = index
                                    vm.showPhotosPicker = true
                                }) {
                                    Text("Change Image")
                                    Image(systemName: "photo.fill")
                                }
                                
                                Button(role: .destructive, action: {
                                    images.remove(at: index)
                                }) {
                                    Text("Delete")
                                    Image(systemName: "trash.fill")
                                }
                            } label: {
                                KFImage(URL(string: images[index]))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:imageDimension, height: imageDimension * 1.3)
                                    .cornerRadius(10)
                                    .clipped()
                            }
                        } else {
                            ZStack(){
                                Color("main-secondary-color")
                                    .frame(width:imageDimension, height: imageDimension * 1.3)
                                    .cornerRadius(10)
                                
                                Image(systemName: "plus.circle")
                                    .foregroundStyle(Color("SelectedFilter"))
                                    .imageScale(.large)
                            }
                            .onTapGesture {
                                vm.selectedImageIndex = index
                                vm.showPhotosPicker = true
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $vm.showPhotosPicker) {
            PhotoPicker(selectedImage: $vm.selectedImage, showCropView: $vm.showCropView)
        }
        .sheet(isPresented: $vm.showCropView) {
            if let imageToCrop = vm.selectedImage {
                CropView(image: imageToCrop, cropSize: CGSize(width: CROPPING_WIDTH, height: CROPPING_HEIGHT)) { croppedImage in
                    if let index = vm.selectedImageIndex {
                        vm.selectedImages[index] = croppedImage
                    }
                    vm.showCropView = false
                } onCancel: {
                    vm.showCropView = false
                }
                .transition(.opacity)
                .interactiveDismissDisabled()
            }
        }
        .frame(maxHeight: .infinity, alignment: .top )
    }
    
}

#Preview {
    PhotosGridView(images: .constant([]), vm: PhotoPickerViewModel(s3BucketName: .club, mode: .edit))
}
