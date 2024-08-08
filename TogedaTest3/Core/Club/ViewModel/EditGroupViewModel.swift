//
//  EditGroupViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 5.01.24.
//

import SwiftUI
import PhotosUI
import Combine
import MapKit

class EditGroupViewModel: ObservableObject {

    @Published var editClub: Components.Schemas.ClubDto = MockClub
    @Published var initialClub: Components.Schemas.ClubDto = MockClub
    
    @Published var description: String = "" {
        didSet{
            if !description.isEmpty{
                editClub.description = description
            } else {
                editClub.description = nil
            }
        }
    }
    @Published var returnedPlace = Place(mapItem: MKMapItem()){
        didSet{
            editClub.location = .init(name: returnedPlace.address, address: returnedPlace.street, city: returnedPlace.city, state: returnedPlace.state, country: returnedPlace.country, latitude: returnedPlace.latitude, longitude: returnedPlace.longitude)
        }
    }

    @Published var selectedInterests: [Interest] = []{
        didSet{
            editClub.interests = selectedInterests.map({ Interest in
                Components.Schemas.Interest(name: Interest.name, icon: Interest.icon, category: Interest.category)
            })
        }
    }
    @Published var selectedVisability: String = "PUBLIC" {
        didSet{
            editClub.accessibility = .init(rawValue: selectedVisability)!
        }
    }
    @Published var selectedPermission: Permissions = .All_members{
        didSet{
            editClub.permissions = .init(rawValue: selectedPermission.backendValue)!
        }
    }
    
    func convertToPatchClub() -> Components.Schemas.PatchClubDto {

        
        let club = Components.Schemas.PatchClubDto(
            title: editClub.title,
            images: editClub.images,
            description: editClub.description,
            location: editClub.location,
            interests: editClub.interests,
            accessibility: .init(rawValue: selectedVisability)!,
            permissions: .init(rawValue: selectedPermission.backendValue)!,
            askToJoin: editClub.askToJoin
        )
        
        return club
    }
    
    @Published var isInit: Bool = true
    
    func fetchClubData(club: Components.Schemas.ClubDto) {
        editClub = club
        initialClub = club
        
        description = club.description ?? ""
        selectedInterests = club.interests.map({ interest in
            Interest(name: interest.name, icon: interest.icon, category: interest.category)
        })
        selectedVisability = club.accessibility.rawValue
        
        if club.permissions == .ADMINS_ONLY {
            selectedPermission = .Admins_only
        } else {
            selectedPermission = .All_members
        }
    }
    
}
