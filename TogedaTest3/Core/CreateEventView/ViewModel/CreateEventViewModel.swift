//
//  CreateEventViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 14.10.23.
//

import Foundation
import MapKit

class CreateEventViewModel: ObservableObject {
    //Title
    @Published var title: String = ""
    
    //Participants View
    @Published var showParticipants = false
    @Published var participants: Int?
    
    //Pricing View
    @Published var showPricing = false
    @Published var price: Double?
    
    //Location View
    @Published var location: Components.Schemas.BaseLocation?
    @Published var returnedPlace = Place(mapItem: MKMapItem()){
        didSet{
            self.location = .init(name: returnedPlace.address, address: returnedPlace.street, city: returnedPlace.city, state: returnedPlace.state, country: returnedPlace.country, latitude: returnedPlace.latitude, longitude: returnedPlace.longitude)
        }
    }

    //Date View
    @Published var from = Date.now.addingTimeInterval(900)
    {
        didSet{
            if to < from.addingTimeInterval(599) {
                to = from.addingTimeInterval(600)
            }
        }
    }
    @Published var to = Date.now.addingTimeInterval(4500)
    @Published var isDate = true
    @Published var dateTimeSettings = 0
    @Published var showTimeSettings = false
    
    //Description View
    @Published var description: String = ""
    
    //Accesability
    @Published var selectedVisability: String = ""
    @Published var askToJoin: Bool = false
    @Published var club: Components.Schemas.ClubDto?
    
    //Tag
    @Published var selectedInterests: [Interest] = []
    
    //Photos
    @Published var postPhotosURls: [String] = []
    
    //Location Confirmation
    @Published var needsLocationalConfirmation = false
    
    func createPost() -> Components.Schemas.CreatePostDto {
        let interests = selectedInterests.map { interest in
            Components.Schemas.Interest(name: interest.name, icon: interest.icon, category: interest.category)
        }
        
        var fromDate: Date?
        var toDate: Date?
        
        if dateTimeSettings == 0 {
            fromDate = nil
            toDate = nil
        } else if dateTimeSettings == 1 {
            fromDate = from
            toDate = nil
        } else {
            fromDate = from
            toDate = to
        }
        
        var clubId: String? = nil
        
        if let club = self.club {
            clubId = club.id
        }
        
        return .init(
            title: title,
            images: postPhotosURls,
            description: description.isEmpty ? nil : description,
            maximumPeople: (participants == 0 || participants == nil) ? nil : Int32(participants!),
            location: location!,
            interests: interests,
            payment: price != nil ? price! : 0,
            accessibility: .init(rawValue: selectedVisability.uppercased())!,
            askToJoin: askToJoin,
            inClubID: clubId,
            fromDate: fromDate,
            toDate: toDate, 
            needsLocationalConfirmation: needsLocationalConfirmation
        )
    }
}
