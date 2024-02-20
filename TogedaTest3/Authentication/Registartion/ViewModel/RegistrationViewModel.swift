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
    @Published var userId: String?
    @Published var createdUser: CreateUser = .init(
        profilePhotos: [],
        firstName: "",
        lastName: "",
        email: "",
        subToEmail: false,
        password: "",
        phoneNumber: "",
        birthDate: "",
        occupation: "",
        location: nil,
        gender: "",
        visibleGender: true,
        interests: [])
    
    //Birthday
    @Published var day: String = "" {
        didSet{
            createdUser.birthDate = "\(year)-\(month)-\(day)"
        }
    }
    @Published var month: String = "" {
        didSet{
            createdUser.birthDate = "\(year)-\(month)-\(day)"
        }
    }
    @Published var year: String = ""{
        didSet{
            createdUser.birthDate = "\(year)-\(month)-\(day)"
        }
    }
    
    //Location
    @Published var returnedPlace: Place = Place(mapItem: MKMapItem()){
        didSet{
            self.createdUser.location = .init(name: returnedPlace.name, address: returnedPlace.street, city: returnedPlace.city, state: returnedPlace.state, country: returnedPlace.country, latitude: returnedPlace.latitude, longitude: returnedPlace.longitude)
        }
    }
    @Published var isCurrentLocation: Bool = true
    
    //Interests
//    @Published var selectedInterests: [Interest] = []
    
    //Number
    @Published var countryCode: String = "359"
    @Published var countryFlag: String = "🇧🇬"
    @Published var countryPattern: String = "#"
    @Published var countryLimit: Int = 17
    @Published var mobPhoneNumber: String = "" {
        didSet{
            self.createdUser.phoneNumber = "\(countryCode)\(mobPhoneNumber)"
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
        guard let jpeg = compressImageIfNeeded(image: uiImage)else {
            print("Image compression failed.")
            return false
        }
        
        do {
            let response = try await ImageService().generatePresignedPutUrl(bucketName: "togeda-profile-photos", fileName: UUID)
            try await ImageService().uploadImage(imageData: jpeg, urlString: response)
            let imageUrl = "https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/\(UUID).jpeg"
            createdUser.profilePhotos.append(imageUrl)
            
            return true
        } catch {
            print("Upload failed with error: \(error)")
            
            return false
        }
    }
    
//    func saveImage() {
//        createdUser.profilePhotos = []
//        for i in selectedImages {
//            if let image = i {
//                combineImageMethods(uiImage: image, bucketName: "togeda-profile-photos")
//            } else{
//                print("no selected image")
//            }
//        }
//    }
//    
//    func combineImageMethods(uiImage: UIImage, bucketName: String){
//        let jpeg = compressImageIfNeeded(image: uiImage)
//        if let jpegimg = jpeg {
//            Task {
//                do{
//                    let UUID = NSUUID().uuidString
//                    let response = try await ImageService().generatePresignedPutUrl(bucketName: bucketName, fileName: UUID)
//                    try await ImageService().uploadImage(imageData: jpegimg, urlString: response)
//                    createdUser.profilePhotos.append("https://\(bucketName).s3.eu-central-1.amazonaws.com/\(UUID).jpeg")
//                } catch GeneralError.encodingError{
//                    print("Data encoding error")
//                } catch GeneralError.badRequest(details: let details){
//                    print(details)
//                } catch GeneralError.invalidURL {
//                    print("Invalid URL")
//                } catch GeneralError.serverError(let statusCode, let details) {
//                    print("Status: \(statusCode) \n \(details)")
//                } catch {
//                    print("Error message:", error)
//                }
//            }
//        } else {
//            print("no jpeg")
//        }
//    }
    
    @Published var selectedImage: UIImage?
    @Published var showCropView = false
    @Published var interests: [String] = []
    
    @Published var imageselection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageselection)
        }
    }
    
    @Published var places: [Place] = []
    @Published var searchText: String = ""
    
    var cancellable: AnyCancellable?
    @Published var fetchedPlaces: [CLPlacemark]?
    
    init() {
        cancellable = $searchText
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

// Location
extension RegistrationViewModel {
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
