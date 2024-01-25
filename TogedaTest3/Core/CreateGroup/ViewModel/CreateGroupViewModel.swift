//
//  CreateGroupViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 29.12.23.
//

import SwiftUI
import PhotosUI
import MapKit


class CreateGroupViewModel: ObservableObject {
    
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var returnedPlace = Place(mapItem: MKMapItem())

    @Published var selectedInterests: [Interest] = []
    @Published var selectedVisability: Visabilities = .Public
    @Published var askToJoin: Bool = false
    @Published var selectedPermission: Permissions = .All_members
    
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
    
}

// PhotoPicker
extension CreateGroupViewModel {
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
