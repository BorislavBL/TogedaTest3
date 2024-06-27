//
//import SwiftUI
//import Kingfisher
//
//struct EditEventPhotosView: View {
//    @ObservedObject var editEventVM: EditEventViewModel
//    private let imageDimension: CGFloat = (UIScreen.main.bounds.width / 3) - 16
//    @Environment(\.dismiss) private var dismiss
//    
//    var body: some View {
//        Grid {
//            GridRow {
//                ForEach(0..<3, id: \.self){ index in
//                    ZStack{
//                        if let image = editEventVM.selectedImages[index]{
//                            Image(uiImage: image)
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width:imageDimension, height: imageDimension * 1.3)
//                                .cornerRadius(10)
//                                .clipped()
//                        } else if index < editEventVM.editPost.images.count {
//                            KFImage(URL(string: editEventVM.editPost.images[index]))
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width:imageDimension, height: imageDimension * 1.3)
//                                .cornerRadius(10)
//                                .clipped()
//                        } else {
//                            Color("main-secondary-color")
//                                .frame(width:imageDimension, height: imageDimension * 1.3)
//                                .cornerRadius(10)
//                            
//                            Image(systemName: "plus.circle")
//                                .foregroundStyle(Color("SelectedFilter"))
//                                .imageScale(.large)
//                        }
//                    }
//                    .onTapGesture {
//                        editEventVM.selectedImageIndex = index
//                        editEventVM.showPhotosPicker = true
//                    }
//                }
//            }
//            .padding(.bottom, 2)
//            GridRow {
//                ForEach(3..<6, id: \.self){ index in
//                    ZStack{
//                        if let image = editEventVM.selectedImages[index]{
//                            Image(uiImage: image)
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width:imageDimension, height: imageDimension * 1.3)
//                                .cornerRadius(10)
//                                .clipped()
//                        } else if index < editEventVM.editPost.images.count {
//                            KFImage(URL(string: editEventVM.editPost.images[index]))
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width:imageDimension, height: imageDimension * 1.3)
//                                .cornerRadius(10)
//                                .clipped()
//                        } else {
//                            Color("main-secondary-color")
//                                .frame(width:imageDimension, height: imageDimension * 1.3)
//                                .cornerRadius(10)
//                            
//                            Image(systemName: "plus.circle")
//                                .foregroundStyle(Color("SelectedFilter"))
//                                .imageScale(.large)
//                        }
//                    }
//                    .onTapGesture {
//                        editEventVM.selectedImageIndex = index
//                        editEventVM.showPhotosPicker = true
//                    }
//                }
//            }
//        }
//        .photosPicker(isPresented: $editEventVM.showPhotosPicker, selection: $editEventVM.imageselection, matching: .images)
//        .fullScreenCover(isPresented: $editEventVM.showCropView, content: {
//            CropPhotoView(selectedImage:editEventVM.selectedImage, finalImage: $editEventVM.selectedImages[editEventVM.selectedImageIndex ?? 0], crop: .custom(CGSize(width: 300, height: 500)))
//        })
//        .frame(maxHeight: .infinity, alignment: .top )
//    }
//    
//}
//
//#Preview {
//    EditEventPhotosView(editEventVM: EditEventViewModel())
//}
