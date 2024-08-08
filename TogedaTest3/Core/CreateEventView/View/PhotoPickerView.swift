//
//  PhotoPickerView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 16.10.23.
//

import SwiftUI
import PhotosUI
import Kingfisher

struct PhotoPickerView: View {
    @ObservedObject var photoPickerVM: PhotoPickerViewModel
    private let imageDimension: CGFloat = (UIScreen.main.bounds.width / 3) - 16
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment:.leading, spacing: 10){
                    Text("Add photos related to your activity.")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                
                NormalPhotosGridView(vm: photoPickerVM)
                
                if photoPickerVM.selectedImages.allSatisfy({ $0 == nil }), let user = userViewModel.currentUser{
                    
                    Text("Use your ptofile picture as the cover for the event.")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                    
                    Button {
                        Task{
                            if let image = await ImageService().urlToUIImage(urlString: user.profilePhotos[0]) {
                                photoPickerVM.selectedImages[0] = image
                            }
                        }
                    } label:{
                        KFImage(URL(string: user.profilePhotos[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: imageDimension, height: imageDimension * 1.3)
                            .cornerRadius(10)
                            .clipped()
                    }
                }
                
            }

        }
        .swipeBack()
//        .photosPicker(isPresented: $photoPickerVM.showPhotosPicker, selection: $photoPickerVM.imageselection, matching: .images)
//        .fullScreenCover(isPresented: $photoPickerVM.showCropView, content: {
//            CropPhotoView(selectedImage:photoPickerVM.selectedImage, finalImage: $photoPickerVM.selectedImages[photoPickerVM.selectedImageIndex ?? 0], crop: .custom(CGSize(width: CROPPING_WIDTH, height: CROPPING_HEIGHT)))
//        })
//        .sheet(isPresented: $photoPickerVM.showPhotosPicker) {
//            PhotoPicker(selectedImage: $photoPickerVM.selectedImage, cropSize: CGSize(width: CROPPING_WIDTH, height: CROPPING_HEIGHT))
//        }
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
    PhotoPickerView(photoPickerVM: PhotoPickerViewModel(s3BucketName: .user, mode: .normal))
        .environmentObject(UserViewModel())
}
