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
    
    @Published var club: Club = .MOCK_CLUBS[0]
    
    @Published var title: String = ""
    
    @Published var location: baseLocation = mockLocation
    
    @Published var description: String = ""
    @Published var interests: [Interest] = []
    @Published var returnedPlace = Place(mapItem: MKMapItem()) {
        didSet{
            self.location = baseLocation(name: returnedPlace.name, latitude: returnedPlace.latitude, longitude: returnedPlace.longitude)
        }
    }
    
    @Published var showPhotosPicker = false
    @Published var selectedImageIndex: Int?
    @Published var selectedImages: [Image?] = [nil, nil, nil, nil, nil, nil]
    @Published var selectedImage: UIImage?
    @Published var showCropView = false
    
    @Published var imageselection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageselection)
        }
    }
    
    @Published var places: [Place] = []
    @Published var searchLocationText: String = ""
    
    var cancellable: AnyCancellable?
    @Published var fetchedPlaces: [CLPlacemark]?
    
    init() {
        fetchGroupData()
        cancellable = $searchLocationText
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
extension EditGroupViewModel {
    private func fetchGroupData() {
        description = club.description ?? ""
        location = club.baseLocation
        interests = club.interests
        searchLocationText = club.baseLocation.name
        
        for i in club.imagesUrl.indices {
            selectedImages[i] = Image(User.MOCK_USERS[0].profileImageUrl[i])
        }
    }
    

    
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
extension EditGroupViewModel {
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
    
}
