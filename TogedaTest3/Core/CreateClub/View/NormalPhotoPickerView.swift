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
                
                NormalPhotosGridView(vm: photoPickerVM)
                
            }
            
        }
        .swipeBack()
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
