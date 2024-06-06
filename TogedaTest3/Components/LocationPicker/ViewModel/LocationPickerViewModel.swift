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

enum SearchType {
    case all
    case cityAndCountry
}

@MainActor
class LocationPickerViewModel: ObservableObject {
    
    var searchType: SearchType
    
    @Published var places: [Place] = []
    @Published var searchText: String = ""
    
    var cancellable: AnyCancellable?
    @Published var fetchedPlaces: [CLPlacemark]?
    @Published var isCurrentLocation: Bool = false
    
    init(searchType: SearchType) {
        self.searchType = searchType
        self.setupBindings()
    }
    
    private func setupBindings() {
        cancellable = $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { [weak self] value in
                if !value.isEmpty {
                    switch self?.searchType {
                    case .all:
                        self?.searchAll(text: value)
                    case .cityAndCountry:
                        self?.searchCityAndCountry1(text: value)
                    case .none:
                        self?.places = []
                    }
                } else {
                    self?.places = []
                }
            })
    }
    
    func searchAll(text: String){
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
    

    
    func searchCityAndCountry(text: String){
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
    
    func searchCityAndCountry1(text: String){
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
    
//    func searchFilter(text: String){
//        let searchRequest = MKLocalSearch.Request()
//        searchRequest.naturalLanguageQuery = text
//        let search = MKLocalSearch(request: searchRequest)
//        
//        search.start { response, error in
//            guard let response = response else {
//                print(":( ERROR: \(error?.localizedDescription ?? "Uknown Error")")
//                return
//            }
//            
//            self.places = response.mapItems.filter { item in
//                (item.placemark.locality != nil || item.placemark.country != nil) && item.placemark.subThoroughfare == nil
//            }.map(Place.init)
//        }
//    }
//    
//    func search(text: String, region: MKCoordinateRegion){
//        let searchRequest = MKLocalSearch.Request()
//        searchRequest.naturalLanguageQuery = text
//        searchRequest.region = region
//        let search = MKLocalSearch(request: searchRequest)
//        
//        search.start { response, error in
//            guard let response = response else {
//                print(":( ERROR: \(error?.localizedDescription ?? "Uknown Error")")
//                return
//            }
//            
//            self.places = response.mapItems.map(Place.init)
//        }
//    }
}
