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
    @Published var returnedPlace = Place(mapItem: MKMapItem())
    
    //Date View
    @Published var date = Date()
    @Published var from = Date()
    @Published var to = Date()
    @Published var isDate = true
    @Published var daySettings = 0
    @Published var timeSettings = 0
    
    //Description View
    @Published var description: String = ""
    
    //Accesability
    @Published var selectedVisability: Visabilities?
    @Published var askToJoin: Bool = false
    
    //Category
    @Published var selectedCategory: String?
    @Published var selectedInterests: [String] = []
}
