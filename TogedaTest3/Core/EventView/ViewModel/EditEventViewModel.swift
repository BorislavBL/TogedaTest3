//
//  EditEventViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.01.24.
//

import SwiftUI
import PhotosUI
import MapKit

@MainActor
class EditEventViewModel: ObservableObject {
    @Published var editPost: Components.Schemas.PostResponseDto = MockPost
    @Published var initialPost: Components.Schemas.PostResponseDto = MockPost
    
    @Published var description: String = "" {
        didSet{
            if !description.isEmpty{
                editPost.description = description
            } else {
                editPost.description = nil
            }
        }
    }
    
    @Published var returnedPlace = Place(mapItem: MKMapItem()){
        didSet{
            editPost.location = .init(
                name: returnedPlace.name,
                address: returnedPlace.street,
                city: returnedPlace.city,
                state: returnedPlace.state,
                country: returnedPlace.country,
                latitude: returnedPlace.latitude,
                longitude: returnedPlace.longitude)
        }
    }
    
    @Published var selectedInterests: [Interest] = [] {
        didSet{
            editPost.interests = selectedInterests.map({ Interest in
                Components.Schemas.Interest(name: Interest.name, icon: Interest.icon, category: Interest.category)
            })
        }
    }
    
    //Participants View
    @Published var showParticipants = false
    
    //Date View
    @Published var from = Date().addingTimeInterval(900)
    @Published var to = Date().addingTimeInterval(4500)
    @Published var isDate = true
    @Published var dateTimeSettings = 0
    @Published var showTimeSettings: Bool = false
    @Published var isInit: Bool = true
    
    //Photos
    @Published var showPhotosPicker = false
    @Published var selectedImageIndex: Int?
    @Published var selectedImages: [UIImage?] = [nil, nil, nil, nil, nil, nil]
    @Published var selectedImage: UIImage?
    @Published var showCropView = false
    
    @Published var publishedPhotosURLs: [String?] = [nil, nil, nil, nil, nil, nil]
    
    @Published var imageselection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageselection)
        }
    }
}

// Photo
extension EditEventViewModel {
    func fetchPostData(post: Components.Schemas.PostResponseDto) {
        editPost = post
        initialPost = post
        
        if let fromDate = post.fromDate {
            from = fromDate
        }
         
        if let toDate = post.toDate{
            to = toDate
        }
        
        description = post.description ?? ""
        selectedInterests = post.interests.map({ interest in
            Interest(name: interest.name, icon: interest.icon, category: interest.category)
        })
    }

    
    func convertToPathcPost(post: Components.Schemas.PostResponseDto) -> Components.Schemas.PatchPostDto {
        
        var fromDate: Date?
        var toDate: Date?
        
        if dateTimeSettings == 0 {
            fromDate = from
            toDate = nil
        } else if dateTimeSettings == 1 {
            fromDate = from
            toDate = to
        } else {
            fromDate = nil
            toDate = nil
        }
        
        let post = Components.Schemas.PatchPostDto(
            title: post.title,
            images: post.images,
            description: post.description,
            maximumPeople: post.maximumPeople,
            location: post.location,
            interests: post.interests,
            payment: post.payment,
            accessibility: .init(rawValue: post.accessibility.rawValue),
            hasEnded: post.hasEnded,
            fromDate: fromDate,
            toDate: toDate
        )
        
        return post
    }
}

extension EditEventViewModel {
    
    func imageCheckAndMerge() async -> Bool {
        if await self.saveImages() {
            //Image check
            for (index, image) in publishedPhotosURLs.enumerated() {
                if let image = image {
                    if editPost.images.count > index {
                        editPost.images[index] = image
                    } else {
                        editPost.images.append(image)
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
    
    func saveImages() async -> Bool {
        var isSuccess = true
        publishedPhotosURLs = [nil, nil, nil, nil, nil, nil]
        
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
        let bucketName = "togeda-post-photos"
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
            publishedPhotosURLs[index] = imageUrl
            
            return true
        } catch {
            print("Upload failed with error: \(error)")
            
            return false
        }
    }
    
}
