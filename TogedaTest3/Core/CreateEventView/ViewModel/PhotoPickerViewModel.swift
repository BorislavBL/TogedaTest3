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
    @Published var publishedPhotosURLs: [String] = []
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
    
    func saveImages() async -> Bool {
        var isSuccess = true
        publishedPhotosURLs = []
        
        await withTaskGroup(of: Bool.self) { group in
            for image in selectedImages {
                if let image = image {
                    group.addTask {
                        return await self.uploadImageAsync(uiImage: image)
                    }
                }
            }
            for await result in group {
                if !result {
                    isSuccess = false
                }
            }
        }
        return isSuccess
    }
    
    private func uploadImageAsync(uiImage: UIImage) async -> Bool {
        let bucketName = "togeda-post-photos"
        let UUID = NSUUID().uuidString
        guard let jpeg = compressImageIfNeeded(image: uiImage)else {
            print("Image compression failed.")
            return false
        }
        
        do {
            let response = try await ImageService().generatePresignedPutUrl(bucketName: bucketName, fileName: UUID)
            try await ImageService().uploadImage(imageData: jpeg, urlString: response)
            let imageUrl = "https://\(bucketName).s3.eu-central-1.amazonaws.com/\(UUID).jpeg"
            publishedPhotosURLs.append(imageUrl)
            
            return true
        } catch {
            print("Upload failed with error: \(error)")
            
            return false
        }
    }
    
}


