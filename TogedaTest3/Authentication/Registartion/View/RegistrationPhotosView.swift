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
    @ObservedObject var photoVM: PhotoPickerViewModel
    
    var body: some View {
        VStack(){
            Text("Add Profile Photos")
                .multilineTextAlignment(.center)
                .font(.title).bold()
                .padding(.top, 20)
            
            NormalPhotosGridView(vm: photoVM)
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
                    if await photoVM.saveImages() {
                        vm.profilePhotos = photoVM.publishedPhotosURLs
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
            .disableWithOpacity(photoVM.selectedImages.allSatisfy({ $0 == nil }))
            .onTapGesture {
                if photoVM.selectedImages.allSatisfy({ $0 == nil }) {
                    displayError.toggle()
                }
            }
            
        }
        .padding()
        .navigationDestination(isPresented: $isActive, destination: {
            RegistartionInterestsView(vm: vm)
        })
        .swipeBack()
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
    RegistrationPhotosView(vm: RegistrationViewModel(), photoVM: PhotoPickerViewModel(s3BucketName: .user, mode: .normal))
}
