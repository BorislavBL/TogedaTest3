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
    @Published var location: baseLocation?
    @Published var returnedPlace = Place(mapItem: MKMapItem()){
        didSet{
            self.location = baseLocation(name: returnedPlace.name, address: returnedPlace.street, city: returnedPlace.city, state: returnedPlace.state, country: returnedPlace.country, latitude: returnedPlace.latitude, longitude: returnedPlace.longitude)
        }
    }

    //Date View
    @Published var date = Date()
    @Published var from = Date().addingTimeInterval(900)
    @Published var to = Date().addingTimeInterval(4500)
    @Published var isDate = true
    @Published var daySettings = 0
    @Published var timeSettings = 0
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
    
    func createPost() -> CreatePost {
        let dateFrom = formatDateAndTimeToStringTimeFormat(date: from)
        let dateTo = formatDateAndTimeToStringTimeFormat(date: to)
        return .init(
            title: title,
            images: postPhotosURls,
            description: description.isEmpty ? nil : description,
            maximumPeople: participants,
            location: location!,
            fromDate: (timeSettings == 0 || timeSettings == 1) ? dateFrom : nil,
            toDate: (timeSettings == 1) ? dateTo : nil,
            interests: selectedInterests,
            payment: price != nil ? price! : 0,
            accessibility: selectedVisability,
            askToJoin: askToJoin,
            inClubID: nil)
    }
}
