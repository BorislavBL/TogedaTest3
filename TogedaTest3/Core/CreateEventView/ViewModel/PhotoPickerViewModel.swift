//
//  PhotoPickerViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 16.10.23.
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
class PhotoPickerViewModel: ObservableObject {
    @Published var showPhotosPicker = false
    @Published var selectedImageIndex: Int?
    @Published var selectedImages: [UIImage?] = [nil, nil, nil, nil, nil, nil]
    @Published var selectedImage: UIImage?
    @Published var showCropView = false
    
    @Published var imageselection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageselection)
        }
    }
    
    
    @Published var eventSelectedImages: [UIImage] = []
    @Published var imagesSelection: [PhotosPickerItem] = [] {
        didSet {
            setImages(from: imagesSelection)
        }
    }
    
    private func setImage(from selection: PhotosPickerItem?){
        guard let selection else {return}
        
        Task {
//            if let data = try? await selection.loadTransferable(type: Data.self) {
//                if let uiImage = UIImage(data: data){
//                    selectedImage = uiImage
//                    return
//                }
//            }
            
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                
                selectedImage = uiImage
                showCropView = true
//                if let index = selectedImageIndex {
//                    
//                    selectedImages[index] = uiImage
//                    showCropView = true
//                }
            } catch {
                print(error)
            }
        }
    }
    
//    private func setImages(from selections: [PhotosPickerItem]){
//        Task{
//            var images: [UIImage] = []
//            for selection in selections {
//                if let data = try? await selection.loadTransferable(type: Data.self) {
//                    if let uiImage = UIImage(data: data){
//                        images.append(uiImage)
//                        return
//                    }
//                }
//            }
//            eventSelectedImages = images
//        }
//    }
 
    private func setImages(from selections: [PhotosPickerItem]){
        Task {
            var images: [UIImage] = []
            for selection in selections {
                do {
                    if let data = try await selection.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data){
                            images.append(uiImage)
                        }
                    }
                } catch {
                    print("Error loading image: \(error)")
                }
            }
            // After all images are loaded, then update your published property
            DispatchQueue.main.async {
                self.eventSelectedImages = images
            }
        }
    }
    
}


