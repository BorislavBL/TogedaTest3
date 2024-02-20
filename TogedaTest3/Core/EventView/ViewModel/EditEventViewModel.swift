//
//  EditEventViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.01.24.
//

import SwiftUI
import PhotosUI
import MapKit

class EditEventViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    
    @Published var location: baseLocation?
    @Published var returnedPlace = Place(mapItem: MKMapItem()){
        didSet{
            self.location = baseLocation(name: returnedPlace.name, address: returnedPlace.street, city: returnedPlace.city, state: returnedPlace.state, country: returnedPlace.country, latitude: returnedPlace.latitude, longitude: returnedPlace.longitude)
        }
    }
    
    @Published var selectedInterests: [Interest] = []
    
    //Participants View
    @Published var showParticipants = false
    @Published var participants: Int?
    
    //Date View
    @Published var date = Date()
    @Published var from = Date()
    @Published var to = Date()
    @Published var isDate = true
    @Published var daySettings = 0
    @Published var timeSettings = 0
    @Published var showTimeSettings: Bool = false
    
    //Photos
    @Published var showPhotosPicker = false
    @Published var selectedImageIndex: Int?
    @Published var selectedImages: [UIImage?] = [nil, nil, nil, nil, nil, nil]
    @Published var selectedImage: UIImage?
    @Published var showCropView = false
    
    @Published var imageselection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageselection)
        }
    }
}

// Photo
extension EditEventViewModel {
    func fetchPostData(post: Post) {
        title = post.title
        description = post.description ?? ""
        selectedInterests = post.interests
        participants = post.maximumPeople
        
        for i in post.imageUrl.indices {
            selectedImages[i] = UIImage(named: User.MOCK_USERS[0].profilePhotos[i])
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
