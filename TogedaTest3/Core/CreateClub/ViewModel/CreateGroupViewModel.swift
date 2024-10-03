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
class CreateClubViewModel: ObservableObject {
    
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var location: Components.Schemas.BaseLocation?
    @Published var returnedPlace = Place(mapItem: MKMapItem()){
        didSet{
            self.location = .init(name: returnedPlace.address, address: returnedPlace.street, city: returnedPlace.city, state: returnedPlace.state, country: returnedPlace.country, latitude: returnedPlace.latitude, longitude: returnedPlace.longitude)
        }
    }

    @Published var selectedInterests: [Interest] = []
    @Published var selectedVisability: String = "PUBLIC"
    @Published var askToJoin: Bool = false
    @Published var selectedPermission: Permissions = .All_members
    
    
    @Published var publishedPhotosURLs: [String] = []
    
    func createClub() -> Components.Schemas.CreateClubDto {
        let interests = selectedInterests.map { interest in
            Components.Schemas.Interest(name: interest.name, icon: interest.icon, category: interest.category)
        }
        
        return .init(
            title: title,
            images: publishedPhotosURLs,
            description: description.isEmpty ? nil : description,
            location: location!,
            interests: interests,
            accessibility: .init(rawValue: selectedVisability.uppercased())!,
            permissions: .init(rawValue: selectedPermission.backendValue)!,
            askToJoin: askToJoin
        )
    }
    
}
