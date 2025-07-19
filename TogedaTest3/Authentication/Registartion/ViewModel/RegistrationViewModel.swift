//
//  RegistrationViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.12.23.
//

import SwiftUI
import PhotosUI
import MapKit
import Combine

enum AccountType {
    case personal, business
}

@MainActor
class RegistrationViewModel: ObservableObject {
//    @Published var userId: String?
    
    func addUserInfoModel() -> Components.Schemas.UserDto{
        let createdUser: Components.Schemas.UserDto = .init(
            subToEmail: subToEmail,
            firstName: trimAndLimitWhitespace(firstName),
            lastName: trimAndLimitWhitespace(lastName),
            gender: gender!,
            birthDate: birthDayFromStringToDate(dateString: birthDate)!,
            visibleGender: visibleGender,
            occupation: trimAndLimitWhitespace(occupation),
            profilePhotos: profilePhotos,
            interests: selectedInterests.map({ interest in
                    .init(name: interest.name, icon: interest.icon, category: interest.category)
            }),
            phoneNumber: phoneNumber,
            location: .init(
                name: returnedPlace.name,
                address: returnedPlace.street,
                city: returnedPlace.city,
                state: returnedPlace.state,
                country: returnedPlace.country,
                latitude: returnedPlace.latitude,
                longitude: returnedPlace.longitude),
            referralCodeUsed: referralCode.isEmpty ? nil : referralCode
            )
        
        return createdUser
    }
    
    @Published var referralCode: String = ""
    @Published var subToEmail: Bool = false
    //Name
    @Published var firstName = ""
    @Published var lastName = ""
    
    //Occupation
    @Published var occupation = ""
    
    //Gender
    @Published var gender: Components.Schemas.UserDto.genderPayload?
    @Published var visibleGender = true
    
    //Photos
    @Published var profilePhotos: [String] = []
    
    //Birthday
    @Published var birthDate = ""
    
    @Published var day: String = "" {
        didSet{
            birthDate = "\(year)-\(month)-\(day)"
        }
    }
    @Published var month: String = "" {
        didSet{
            birthDate = "\(year)-\(month)-\(day)"
        }
    }
    @Published var year: String = ""{
        didSet{
            birthDate = "\(year)-\(month)-\(day)"
        }
    }
    

    @Published var returnedPlace: Place = Place(mapItem: MKMapItem())

    @Published var isCurrentLocation: Bool = true
    
    //Interests
    @Published var selectedInterests: [Interest] = []
    
    //Number
    @Published var phoneNumber: String = ""
    @Published var countryCode: String = "359"
    @Published var countryFlag: String = "🇧🇬"
    @Published var countryPattern: String = "#"
    @Published var countryLimit: Int = 17
    @Published var mobPhoneNumber: String = "" {
        didSet{
            self.phoneNumber = "\(countryCode)\(mobPhoneNumber)"
        }
    }
    
    //Code
    @Published var code: String = ""
    
    //Photos
    @Published var showPhotosPicker = false
    @Published var selectedImageIndex: Int?
    @Published var selectedImages: [UIImage?] = [nil, nil, nil, nil, nil, nil]
        
    func saveImages() async -> Bool {
        var isSuccess = true
        
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
        let bucketName = "togeda-profile-photos"
//        guard let jpeg = compressImageIfNeeded(image: uiImage) else {
//            print("Image compression failed.")
//            return false
//        }
        
        guard let jpeg = uiImage.jpegData(compressionQuality: 1.0) else {
            print("Image compression failed.")
            return false
        }
        
        do {
            if let response = try await APIClient.shared.generatePresignedPutUrl(bucketName: bucketName, keyName: UUID) {            try await ImageService().uploadImage(imageData: jpeg, urlString: response)
                
                let imageUrl = "https://\(bucketName).s3.eu-central-1.amazonaws.com/\(UUID).jpeg"
                profilePhotos.append(imageUrl)
                
                return true
            } else {
                return false
            }
        } catch {
            print("Upload failed with error: \(error)")
            
            return false
        }
    }
    
    
    @Published var selectedImage: UIImage?
    @Published var showCropView = false
    
    @Published var imageselection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageselection)
        }
    }

}

// Photo
extension RegistrationViewModel {
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


// load number
extension RegistrationViewModel {
    func loadJsonData() -> [CPData] {
        guard let url = Bundle.main.url(forResource: "CountryNumbers", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Json file not found")
            return []
        }
        do {
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode([CPData].self, from: data)
            return jsonData
        } catch {
            print("Error decoding JSON: \(error)")
            return []
        }
    }
    
}

