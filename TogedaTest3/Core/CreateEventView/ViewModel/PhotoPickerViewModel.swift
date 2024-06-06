//
//  PhotoPickerViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 16.10.23.
//

import Foundation
import SwiftUI
import PhotosUI

enum bucketName {
    case user
    case post
    case club
    
    var rawValue: String {
        switch self {
        case .user:
            return "togeda-profile-photos"
        case .post:
            return "togeda-post-photos"
        case .club:
            return "togeda-club-photos"
        }
    }
}

enum photoPickerMode {
    case normal
    case edit
}

@MainActor
class PhotoPickerViewModel: ObservableObject {
    
    var s3BucketName: bucketName
    var mode: photoPickerMode
    
    init(s3BucketName: bucketName, mode: photoPickerMode) {
        self.s3BucketName = s3BucketName
        self.mode = mode
    }
    
    @Published var showPhotosPicker = false
    @Published var selectedImageIndex: Int?
    @Published var selectedImages: [UIImage?] = [nil, nil, nil, nil, nil, nil]
    @Published var publishedPhotosURLs: [String] = []
    @Published var selectedImage: UIImage?
    @Published var showCropView = false
    
    @Published var editPublishedPhotosURLs: [String?] = [nil, nil, nil, nil, nil, nil]
    
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
    
    func imageCheckAndMerge(images: Binding<[String]>) async -> Bool {
        if await self.saveImages() {
            // Image check
            for (index, image) in editPublishedPhotosURLs.enumerated() {
                if let image = image {
                    if images.wrappedValue.count > index {
                        images.wrappedValue[index] = image
                    } else {
                        images.wrappedValue.append(image)
                    }
                }
            }
            return true
        } else {
            return false
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
            for (index, image) in selectedImages.enumerated() {
                if let image = image {
                    group.addTask {
                        return await self.uploadImageAsync(uiImage: image, index: index)
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
    
    private func uploadImageAsync(uiImage: UIImage, index: Int) async -> Bool {
        let bucketName = s3BucketName.rawValue
        let UUID = NSUUID().uuidString
        //        guard let jpeg = compressImageIfNeeded(image: uiImage) else {
        //            print("Image compression failed.")
        //            return false
        //        }
                
                guard let jpeg = uiImage.jpegData(compressionQuality: 1.0) else {
                    print("Image compression failed.")
                    return false
                }
        
        do {
            let response = try await ImageService().generatePresignedPutUrl(bucketName: bucketName, fileName: UUID)
            try await ImageService().uploadImage(imageData: jpeg, urlString: response)
            let imageUrl = "https://\(bucketName).s3.eu-central-1.amazonaws.com/\(UUID).jpeg"
            
            switch mode {
            case .normal:
                publishedPhotosURLs.append(imageUrl)
            case .edit:
                editPublishedPhotosURLs[index] = imageUrl
            }
            
            
            
            return true
        } catch {
            print("Upload failed with error: \(error)")
            
            return false
        }
    }
    
}


