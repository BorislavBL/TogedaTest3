//
//  LocationPickerViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 11.10.23.
//

import Foundation

import Foundation
import MapKit
import Combine

@MainActor
class LocationPickerViewModel: ObservableObject {
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
                    self.searchTest(text: value)
                } else {
                    self.places = []
                }
            })
    }
    
    func searchTest(text: String){
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
    
    func search(text: String, region: MKCoordinateRegion){
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        searchRequest.region = region
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
