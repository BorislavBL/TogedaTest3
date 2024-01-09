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

class EditProfileViewModel: ObservableObject {
    
    @Published var user: User = User.MOCK_USERS[0]
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var occupation: String = ""
    @Published var email: String = ""
    @Published var gender: String = "Male"
    @Published var baseLocation: baseLocation = mockLocation
    
    @Published var description: String = ""
    
    @Published var workout: String?
    @Published var education: String?
    @Published var personalityType: String?
    @Published var selectedType: ProfileTypes = .workout
    @Published var instagram: String = ""
    @Published var interests: [String] = []
    
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
    
    @Published var places: [Place] = []
    @Published var searchLocationText: String = ""
    
    var cancellable: AnyCancellable?
    @Published var fetchedPlaces: [CLPlacemark]?
    
    init() {
        fetchUserData()
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


// Photo
extension EditProfileViewModel {
    private func fetchUserData() {
        let user = User.MOCK_USERS[0]
        firstName = user.firstName
        lastName = user.lastName
        occupation = user.occipation
        email = user.email
        gender = user.gender
        description = user.bio ?? ""
        workout = user.workout
        education = user.education
        personalityType = user.personalityType
        instagram = user.instagarm ?? ""
        baseLocation = user.baseLocation
        interests = user.interests
        searchLocationText = user.baseLocation.name
        
        for i in user.profileImageUrl.indices {
            selectedImages[i] = Image(User.MOCK_USERS[0].profileImageUrl[i])
        }
    }
    
//    private func updateSelectedImages() {
//        for i in User.MOCK_USERS[0].profileImageUrl.indices {
//            selectedImages[i] = Image(User.MOCK_USERS[0].profileImageUrl[i])
//        }
//    }
    
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
