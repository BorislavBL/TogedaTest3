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
            self.location = .init(name: returnedPlace.name, address: returnedPlace.street, city: returnedPlace.city, state: returnedPlace.state, country: returnedPlace.country, latitude: returnedPlace.latitude, longitude: returnedPlace.longitude)
        }
    }

    //Date View
    @Published var from = Date().addingTimeInterval(900)
    @Published var to = Date().addingTimeInterval(4500)
    @Published var isDate = true
    @Published var dateTimeSettings = 0
    @Published var showTimeSettings = false
    
    //Description View
    @Published var description: String = ""
    
    //Accesability
    @Published var selectedVisability: String = ""
    @Published var askToJoin: Bool = false
    
    //Tag
    @Published var selectedInterests: [Interest] = []
    
    //Photos
    @Published var postPhotosURls: [String] = []
    
    func createPost() -> Components.Schemas.CreatePostDto {
        let interests = selectedInterests.map { interest in
            Components.Schemas.Interest(name: interest.name, icon: interest.icon, category: interest.category)
        }
        
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
            inClubID: nil,
            fromDate: fromDate,
            toDate: toDate
        )
    }
}
