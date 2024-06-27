//
//  CropTestView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 27.06.24.
//

import SwiftUI
import PhotosUI

struct CropTestView: View {
        @State private var selectedImage: UIImage?
        @State private var isShowingPhotoPicker = false

        var body: some View {
            VStack {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    Text("Select an Image")
                        .font(.largeTitle)
                        .padding()
                }
                Button(action: {
                    isShowingPhotoPicker = true
                }) {
                    Text("Pick and crop image")
                }
//                .sheet(isPresented: $isShowingPhotoPicker) {
//                    PhotoPicker(selectedImage: $selectedImage, cropSize: CGSize(width: 500, height: 1000))
//                }
                
            }
            .padding()
        }
    }
#Preview {
    CropTestView()
}
