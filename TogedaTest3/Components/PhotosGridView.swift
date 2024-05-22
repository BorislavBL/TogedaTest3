//
//  PhotosGridView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 5.01.24.
//

import SwiftUI

struct PhotosGridView: View {
    private let imageDimension: CGFloat = (UIScreen.main.bounds.width / 3) - 16
    @Environment(\.dismiss) private var dismiss
    @Binding var showPhotosPicker: Bool
    @Binding var selectedImageIndex: Int?
    @Binding var selectedImages: [UIImage?]

    var body: some View {
        Grid {
            GridRow {
                ForEach(0..<3, id: \.self){ index in
                    ZStack{
                        if let image = selectedImages[index]{
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
                        selectedImageIndex = index
                        showPhotosPicker = true
                    }
                }
            }
            .padding(.bottom, 2)
            GridRow {
                ForEach(3..<6, id: \.self){ index in
                    ZStack{
                        if let image = selectedImages[index]{
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
                        selectedImageIndex = index
                        showPhotosPicker = true
                    }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top )
    }
    
}

#Preview {
    PhotosGridView(showPhotosPicker: .constant(false), selectedImageIndex: .constant(nil), selectedImages: .constant([nil, nil, nil, nil, nil, nil]))
}
