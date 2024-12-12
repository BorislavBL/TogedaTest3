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
    @Published var editUser: Components.Schemas.UserInfoDto = MockUser
    @Published var initialUser: Components.Schemas.UserInfoDto = MockUser

    @Published var returnedPlace: Place = Place(mapItem: MKMapItem()){
        didSet{
            self.editUser.location = .init(name: returnedPlace.addressCountry, address: returnedPlace.street, city: returnedPlace.city, state: returnedPlace.state, country: returnedPlace.country, latitude: returnedPlace.latitude, longitude: returnedPlace.longitude)
        }
    }
    
    @Published var isInit: Bool = true
    
    @Published var interests: [Interest] = [] {
        didSet{
            editUser.interests = interests.map({ Interest in
                Components.Schemas.Interest(name: Interest.name, icon: Interest.icon, category: Interest.category)
            })
        }
    }
    
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
            if !instagram.isEmpty {
                editUser.details.instagram = instagram
            } else {
                editUser.details.instagram = nil
            }
            
        }
    }
    
    @Published var height: String = "" {
        didSet{
            if !instagram.isEmpty {
                editUser.details.height = Int32(height)
            } else {
                editUser.details.height = nil
            }
            
        }
    }
    
    @Published var selectedType: ProfileTypes = .workout
    
    
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
    func fetchUserData(user: Components.Schemas.UserInfoDto) {
        editUser = user
        initialUser = user
        description = user.details.bio ?? ""
        instagram = user.details.instagram ?? ""
        interests = user.interests.map({ interest in
            Interest(name: interest.name, icon: interest.icon, category: interest.category)
        })
        if let userHeight = user.details.height{
            height = "\(userHeight)"
        }
    }
    
    func convertToPathcUser(currentUser: Components.Schemas.UserInfoDto) -> Components.Schemas.PatchUserDto {
        var bio: String? = nil
        if let _bio = currentUser.details.education, !_bio.isEmpty {
            bio = _bio
        }
        
        var education: String? = nil
        if let _education = currentUser.details.education, !_education.isEmpty {
            education = _education
        }
        
        var personalityType: String? = nil
        if let _personalityType = currentUser.details.personalityType, !_personalityType.isEmpty {
            personalityType = _personalityType
        }
        
        var workout: String? = nil
        if let _workout = currentUser.details.workout, !_workout.isEmpty {
            workout = _workout
        }
        
        var instagram: String? = nil
        if let _instagram = currentUser.details.instagram, !_instagram.isEmpty {
            instagram = _instagram
        }
        
        let userDetails = Components.Schemas.UserExtraDetailsDto(
            bio: bio,
            education: education,
            personalityType: personalityType,
            height: currentUser.details.height,
            workout: workout,
            instagram: instagram
        )
        
        let user = Components.Schemas.PatchUserDto(
            subToEmail: currentUser.subToEmail,
            firstName: currentUser.firstName,
            lastName: currentUser.lastName,
            gender: .init(rawValue: currentUser.gender.rawValue),
            birthDate: birthDayFromStringToDate(dateString: currentUser.birthDate),
            visibleGender: currentUser.visibleGender,
            location: currentUser.location,
            occupation: currentUser.occupation,
            phoneNumber: currentUser.phoneNumber,
            details: userDetails,
            interests: currentUser.interests,
            profilePhotos: currentUser.profilePhotos)
        
        return user
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
