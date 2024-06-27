//
//  NormalPhotosGridView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 10.06.24.
//

import SwiftUI
import PhotosUI

struct NormalPhotosGridView: View {
    @ObservedObject var vm: PhotoPickerViewModel
    private let imageDimension: CGFloat = (UIScreen.main.bounds.width / 3) - 16
    @Environment(\.dismiss) private var dismiss
    @State var showPhotosPicker = false
    @State var selectedImage: UIImage?
    
    @State private var isShowingPhotoPicker = false
    @State private var isShowingCropView = false
    @State private var imageToCrop: UIImage?
    @State private var finalImage: UIImage?
    
    var body: some View {
        Grid {
            GridRow {
                ForEach(0..<3, id: \.self){ index in
                    ZStack{
                        if let image = vm.selectedImages[index]{
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
                        vm.selectedImageIndex = index
                        vm.showPhotosPicker = true
                        isShowingPhotoPicker = true
                    }
                }
            }
            GridRow {
                ForEach(3..<6, id: \.self){ index in
                    ZStack{
                        if let image = vm.selectedImages[index]{
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
                        vm.selectedImageIndex = index
                        vm.showPhotosPicker = true
                        isShowingPhotoPicker = true
                    }
                }
            }
        }
//        .photosPicker(isPresented: $vm.showPhotosPicker, selection: $vm.imageselection, matching: .images)
//        .fullScreenCover(isPresented: $vm.showCropView, content: {
//            CropPhotoView(selectedImage:vm.selectedImage, finalImage: $vm.selectedImages[vm.selectedImageIndex ?? 0], crop: .custom(CGSize(width: CROPPING_WIDTH, height: CROPPING_HEIGHT)))
//        })
        .sheet(isPresented: $isShowingPhotoPicker) {
            PhotoPicker(selectedImage: $imageToCrop, finalImage: $finalImage, cropSize: CGSize(width: 500, height: 1000))
                .onDisappear {
                    if let imageToCrop = imageToCrop {
                        isShowingCropView = true
                    }
                }
        }
        .sheet(isPresented: $isShowingCropView) {
            if let imageToCrop = imageToCrop {
                CropView(image: imageToCrop, cropSize: CGSize(width: 500, height: 1000)) { croppedImage in
                    if let index = vm.selectedImageIndex {
                        vm.selectedImages[index] = croppedImage
                    }
                    isShowingCropView = false
                } onCancel: {
                    isShowingCropView = false
                }
                .transition(.opacity)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}


#Preview {
    NormalPhotosGridView(vm: PhotoPickerViewModel(s3BucketName: .club, mode: .normal))
}
