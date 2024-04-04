//
//  EditProfileViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 19.12.23.
//

import SwiftUI
import PhotosUI
import Combine
import MapKit

enum ProfileTypes {
    case workout
    case education
    case personalityType
}

@MainActor
class EditProfileViewModel: ObservableObject{
    @Published var editUser: EditUser = .example
    @Published var initialUser: EditUser = .example

    @Published var returnedPlace: Place = Place(mapItem: MKMapItem()){
        didSet{
            self.editUser.location = baseLocation(name: returnedPlace.name, address: returnedPlace.street, city: returnedPlace.city, state: returnedPlace.state, country: returnedPlace.country, latitude: returnedPlace.latitude, longitude: returnedPlace.longitude)
        }
    }
    
    @Published var isInit: Bool = true
    
    @Published var description: String = "" {
        didSet{
            if !description.isEmpty{
                editUser.details.bio = description
            } else {
                editUser.details.bio = nil
            }
        }
    }
    @Published var instagram: String = "" {
        didSet{
            editUser.details.instagram = instagram
        }
    }
    
    @Published var height: String = "" 
    
    @Published var selectedType: ProfileTypes = .workout
    
    @Published var showPhotosPicker = false
    @Published var selectedImageIndex: Int?
    @Published var selectedImages: [UIImage?] = [nil, nil, nil, nil, nil, nil]
    @Published var publishedPhotosURLs: [String?] = [nil, nil, nil, nil, nil, nil]
    @Published var selectedImage: UIImage?
    @Published var showCropView = false
    
    @Published var imageselection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageselection)
        }
    }
    
    @Published var places: [Place] = []
    @Published var searchLocationText: String = ""
    
    var cancellable: AnyCancellable?
    @Published var fetchedPlaces: [CLPlacemark]?
    
    init() {
        cancellable = $searchLocationText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { value in
                if !value.isEmpty {
                    self.searchFilter(text: value)
                } else {
                    self.places = []
                }
            })
    }

}

extension EditProfileViewModel {
    func fetchUserData(currentUser: User) {
        let user = EditUser(
            subToEmail: currentUser.subToEmail,
            firstName: currentUser.firstName,
            lastName: currentUser.lastName,
            gender: currentUser.gender,
            birthDate: currentUser.birthDate,
            visibleGender: currentUser.visibleGender,
            location: currentUser.location,
            occupation: currentUser.occupation,
            profilePhotos: currentUser.profilePhotos,
            interests: currentUser.interests,
            details: currentUser.details)
        
        editUser = user
        initialUser = user
        description = user.details.bio ?? ""
        instagram = user.details.instagram ?? ""
        
    }
    
    func saveData() async {
            do{
                if await self.saveImages() {
                    //Image check
                    for (index, image) in publishedPhotosURLs.enumerated() {
                        if let image = image {
                            if editUser.profilePhotos.count > index {
                                editUser.profilePhotos[index] = image
                            } else {
                                editUser.profilePhotos.append(image)
                            }
                        }
                    }
                    
                    if editUser != initialUser {
                        let data = try await UserService().editUserDetails(userData: editUser, phoneNumber: nil)
                        print("Success: \(data)")
                    } else {
                        print("No changes")
                    }
                } else {
                    print("No images")
                }
            } catch GeneralError.badRequest(details: let details){
                print(details)
            } catch GeneralError.invalidURL {
                print("Invalid URL")
            } catch GeneralError.serverError(let statusCode, let details) {
                print("Status: \(statusCode) \n \(details)")
            } catch {
                print("Error message:", error)
            }
            
        }

}
    


// Photo
extension EditProfileViewModel {
    
    func imageCheckAndMerge() async -> Bool {
        if await self.saveImages() {
            //Image check
            for (index, image) in publishedPhotosURLs.enumerated() {
                if let image = image {
                    if editUser.profilePhotos.count > index {
                        editUser.profilePhotos[index] = image
                    } else {
                        editUser.profilePhotos.append(image)
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
            let response = try await ImageService().generatePresignedPutUrl(bucketName: "togeda-profile-photos", fileName: UUID)
            try await ImageService().uploadImage(imageData: jpeg, urlString: response)
            let imageUrl = "https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/\(UUID).jpeg"
            publishedPhotosURLs[index] = imageUrl
            
            return true
        } catch {
            print("Upload failed with error: \(error)")
            
            return false
        }
    }
    
}

// Location
extension EditProfileViewModel {
    func searchFilter(text: String){
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let response = response else {
                print(":( ERROR: \(error?.localizedDescription ?? "Uknown Error")")
                return
            }
            
            self.places = response.mapItems.map(Place.init)
        }
    }
    
}
