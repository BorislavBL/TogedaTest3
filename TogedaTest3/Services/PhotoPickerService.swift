//
//  PhotoPickerService.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 5.01.24.
//

import Foundation
import SwiftUI
import PhotosUI

class PhotoPickerService: ObservableObject {
    @Published var showPhotosPicker = false
    @Published var selectedImageIndex: Int?
    @Published var selectedImages: [Image?] = [nil, nil, nil, nil, nil, nil]
    @Published var selectedImage: UIImage?
    @Published var showCropView = false
    
    @Published var imageselection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageselection)
        }
    }
    
    private func setImage(from selection: PhotosPickerItem?){
        guard let selection else {return}
        
        Task {
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                selectedImage = uiImage
                showCropView = true
            } catch {
                print(error)
            }
        }
    }
}
