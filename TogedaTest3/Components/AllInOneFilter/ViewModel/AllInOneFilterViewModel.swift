//
//  AllInOneFilterViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.12.23.
//

import MapKit
import Combine
import SwiftUI

class AllInOneFilterViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var searchText: String = ""
    
    var cancellable: AnyCancellable?
    @Published var fetchedPlaces: [CLPlacemark]?
    @Published var isCurrentLocation: Bool = false
    
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
    
    func searchFilter(text: String){
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
//        searchRequest.resultTypes = .address
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let response = response else {
                print(":( ERROR: \(error?.localizedDescription ?? "Uknown Error")")
                return
            }
            
            self.places = response.mapItems.filter { item in
                (item.placemark.country != nil || item.placemark.locality != nil ) && item.placemark.subThoroughfare == nil
                && (item.name == item.placemark.country || item.name == item.placemark.locality || item.name == item.placemark.administrativeArea || item.name == item.placemark.thoroughfare)
            }.map(Place.init)
        }
    }
    
    func mapItem(from placemark: CLPlacemark) -> MKMapItem {
        let mkPlacemark = MKPlacemark(placemark: placemark)
        return MKMapItem(placemark: mkPlacemark)
    }
    
    func findLocationDetails(location: CLLocation?, returnedPlace: Binding<Place>) {
        guard let location = location else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Error reverse geocoding: \(error.localizedDescription)")
                
            } else if let firstPlacemark = placemarks?.first {
                returnedPlace.wrappedValue = Place(mapItem: self.mapItem(from: firstPlacemark))
            } else {
                print("else")
            }
        }
    }
}
