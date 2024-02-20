//
//  CreateGroupViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 29.12.23.
//

import SwiftUI
import PhotosUI
import MapKit

@MainActor
class CreateGroupViewModel: ObservableObject {
    
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var returnedPlace = Place(mapItem: MKMapItem()){
        didSet{
            self.location = baseLocation(name: returnedPlace.name, address: returnedPlace.street, city: returnedPlace.city, state: returnedPlace.state, country: returnedPlace.country, latitude: returnedPlace.latitude, longitude: returnedPlace.longitude)
        }
    }
    @Published var location: baseLocation?

    @Published var selectedInterests: [Interest] = []
    @Published var selectedVisability: String = "PUBLIC"
    @Published var askToJoin: Bool = false
    @Published var selectedPermission: Permissions = .All_members
    
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
    
    @Published var publishedPhotosURLs: [String] = []
    
    func createClub() -> CreateClub {
        return .init(
            title: title,
            images: publishedPhotosURLs,
            description: description,
            location: location!,
            interests: selectedInterests,
            accessibility: selectedVisability,
            permissions: selectedPermission.backendValue,
            askToJoin: askToJoin
        )
    }
    
}

// PhotoPicker
extension CreateGroupViewModel {
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
        let UUID = NSUUID().uuidString
        guard let jpeg = compressImageIfNeeded(image: uiImage)else {
            print("Image compression failed.")
            return false
        }
        
        do {
            let response = try await ImageService().generatePresignedPutUrl(bucketName: "togeda-profile-photos", fileName: UUID)
            try await ImageService().uploadImage(imageData: jpeg, urlString: response)
            let imageUrl = "https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/\(UUID).jpeg"
            publishedPhotosURLs.append(imageUrl)
            
            return true
        } catch {
            print("Upload failed with error: \(error)")
            
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
}
