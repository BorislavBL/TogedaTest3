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
        profilePhotos: ["https://example.com/photo1.jpg"],
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
        interests: ["hiking", "sport", "startup", "kalata", "hdtv"])
    
    //Birthday
    @Published var day: String = ""
    @Published var month: String = ""
    @Published var year: String = ""
    
    //Location
    @Published var returnedPlace: Place = Place(mapItem: MKMapItem()){
        didSet{
            self.createdUser.location = .init(name: returnedPlace.name, address: returnedPlace.street, city: returnedPlace.city, state: returnedPlace.state, country: returnedPlace.country, latitude: returnedPlace.latitude, longitude: returnedPlace.longitude)
        }
    }
    @Published var isCurrentLocation: Bool = true
    
    //Interests
    @Published var selectedInterests: [Interest] = []
    
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


// Create a user
extension RegistrationViewModel {

    
    
}
