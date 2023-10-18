//
//  LocationPickerViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 11.10.23.
//

import Foundation

import SwiftUI
import MapKit
import Combine

@MainActor
class LocationPickerViewModel: ObservableObject {
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
    
//    extension CLLocation {
//        func placemark(completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> ()) {
//            CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first, $1) }
//        }
//    }
    
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
