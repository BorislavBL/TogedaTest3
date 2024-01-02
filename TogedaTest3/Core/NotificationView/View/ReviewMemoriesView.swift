//
//  ReviewMemoriesView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 7.11.23.
//

import SwiftUI
import PhotosUI

struct ReviewMemoriesView: View {
    @StateObject var photoPickerVM = PhotoPickerViewModel()
    @State var images: [UIImage] = []
    @State var selectedImage: Int = 0
    @State var showImagesViewer: Bool = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack{
            ScrollView{
                LazyVStack(alignment:.center, spacing: 80){
                    Text("Share with your friends some of the memories you have captured during the event.")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    if let _ = photoPickerVM.eventSelectedImages.first {
                        VStack{
                            Button{
                                photoPickerVM.showPhotosPicker = true
                            } label: {
                                Text("Add More Images")
                                    .foregroundStyle(.blue)
                                    .fontWeight(.bold)
                            }
                            ReviewMemoriesTab(images: photoPickerVM.eventSelectedImages, selectedImage: $selectedImage, showImagesViewer: $showImagesViewer)
                        }
                    } else {
                        Button{
                            photoPickerVM.showPhotosPicker = true
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
                    
                }
                .padding()
            }
            
            VStack(){
                Divider()
                
                Button {
                    dismiss()
                } label: {
                    HStack(spacing:2){
                        
                            Text("Finish")
                                .fontWeight(.semibold)
                        
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .cornerRadius(10)
                }
                .padding()
            }
            .background(.bar)
        
        }
        .navigationTitle("Rating")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
        .photosPicker(isPresented: $photoPickerVM.showPhotosPicker, selection: $photoPickerVM.imagesSelection, matching: .images)
    }
}

#Preview {
    ReviewMemoriesView()
}

struct ReviewMemoriesTab: View {
    var images: [UIImage]
    @Binding var selectedImage: Int
    @Binding var showImagesViewer: Bool
    var body: some View {
        VStack{
                HStack {
                    Group{
                        Button{
                            selectedImage = 0
                            showImagesViewer = true
                        } label: {
                            Image(uiImage: images[0])
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .frame(minWidth: 0)
                                .cornerRadius(10)
                                .clipped()
                        }
                        if images.count == 2 {
                            Button{
                                selectedImage = 1
                                showImagesViewer = true
                            } label: {
                                Image(uiImage:images[1])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .frame(minWidth: 0)
                                    .cornerRadius(10)
                                    .clipped()
                            }
                        }
                    }
                }
                if images.count > 2{
                    HStack {
                        Button{
                            selectedImage = 1
                            showImagesViewer = true
                        } label: {
                            Image(uiImage:images[1])
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .frame(minWidth: 0)
                                .cornerRadius(10)
                                .clipped()
                        }
                        
                        Button{
                            selectedImage = 2
                            showImagesViewer = true
                        } label: {
                            Image(uiImage:images[2])
                                .resizable()
                                .scaledToFill()
                                .frame(minWidth: 0)
                                .frame(height: 200)
                                .cornerRadius(10)
                                .clipped()
                        }
                        
                        if images.count >= 4 {

                                Button{
                                    selectedImage = 3
                                    showImagesViewer = true
                                } label: {
                                    ZStack{
                                        Image(uiImage:images[3])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 200)
                                            .frame(minWidth: 0)
                                            .cornerRadius(10)
                                            .clipped()
                                        
                                        
                                        if images.count > 4 {
                                            Rectangle()
                                                .foregroundStyle(.black.opacity(0.5))
                                                .frame(height: 200)
                                                .frame(minWidth: 0)
                                                .cornerRadius(10)
                                            Text("+\(images.count - 4) >")
                                                .foregroundStyle(.white)
                                                .fontWeight(.bold)
                                                .font(.title2)
                                        }
                                    }
                                }
                            
                            
                        }
                    }
                }
 
        }
    }
}
