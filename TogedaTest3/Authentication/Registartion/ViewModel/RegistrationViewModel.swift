//
//  RegistrationViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.12.23.
//

import SwiftUI
import PhotosUI
import MapKit
import Combine

enum AccountType {
    case personal, business
}

class RegistrationViewModel: ObservableObject {
    @Published var showPhotosPicker = false
    @Published var selectedImageIndex: Int?
    @Published var selectedImages: [Image?] = [nil, nil, nil, nil, nil, nil]
    @Published var selectedImage: UIImage?
    @Published var showCropView = false
    @Published var interests: [String] = []
    
    @Published var imageselection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageselection)
        }
    }
    
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
                    self.searchFilter(text: value)
                } else {
                    self.places = []
                }
            })
    }


}

// Photo
extension RegistrationViewModel {
    private func setImage(from selection: PhotosPickerItem?){
        guard let selection else {return}
        
        Task {
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                
                selectedImage = uiImage
                showCropView = true
            } catch {
                print(error)
            }
        }
    }
}

// Location
extension RegistrationViewModel {
    func searchFilter(text: String){
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
}
