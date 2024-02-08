//
//  RegistrationPhotosView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.12.23.
//

import SwiftUI

struct RegistrationPhotosView: View {
    @ObservedObject var vm: RegistrationViewModel
    private let imageDimension: CGFloat = (UIScreen.main.bounds.width / 3) - 16
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var displayError: Bool = false
    @State private var isActive: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(){
            Text("Add Profile Photos")
                .multilineTextAlignment(.center)
                .font(.title).bold()
                .padding(.top, 20)
            
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
                                backgroundColor
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
                                backgroundColor
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
                        }
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 15)
            
            if displayError {
                WarningTextComponent(text: "You have to add at least one profile image.")
                    .padding(.bottom, 15)
            }
            
            Spacer()
            
            Button{
                Task{
                    isLoading = true
                    if await vm.saveImages() {
                        print(vm.createdUser.profilePhotos)
                        isActive = true
                    }
                    isLoading = false
                }
            } label:{
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .cornerRadius(10)
                    .fontWeight(.semibold)
            }
            .disableWithOpacity(vm.selectedImages.allSatisfy({ $0 == nil }))
            .onTapGesture {
                if vm.selectedImages.allSatisfy({ $0 == nil }) {
                    displayError.toggle()
                }
            }
            
        }
        .padding(.horizontal)
        
        .photosPicker(isPresented: $vm.showPhotosPicker, selection: $vm.imageselection, matching: .images)
        .fullScreenCover(isPresented: $vm.showCropView, content: {
            CropPhotoView(selectedImage:vm.selectedImage, finalImage: $vm.selectedImages[vm.selectedImageIndex ?? 0], crop: .custom(CGSize(width: 300, height: 500)))
        })
        .padding(.vertical)
        .navigationDestination(isPresented: $isActive, destination: {
            RegistartionInterestsView(vm: vm)
        })
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .frame(width: 35, height: 35)
                .background(Color(.tertiarySystemFill))
                .clipShape(Circle())
        })
    }
    
    var foregroundColor: Color {
        if colorScheme == .dark {
            return Color(.white)
        } else {
            return Color(.black)
        }
    }
    
    var backgroundColor: Color {
        if colorScheme == .dark {
            return Color(.systemGray5)
        } else {
            return Color(.systemGray6)
        }
    }
    
}

#Preview {
    RegistrationPhotosView(vm: RegistrationViewModel())
}
