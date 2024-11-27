//
//  EditEventViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.01.24.
//

import SwiftUI
import PhotosUI
import MapKit

@MainActor
class EditEventViewModel: ObservableObject {
    @Published var editPost: Components.Schemas.PostResponseDto = MockPost
    @Published var initialPost: Components.Schemas.PostResponseDto = MockPost
    
    @Published var description: String = "" {
        didSet{
            if !description.isEmpty{
                editPost.description = description
            } else {
                editPost.description = nil
            }
        }
    }
    
    @Published var returnedPlace = Place(mapItem: MKMapItem()){
        didSet{
            editPost.location = .init(
                name: returnedPlace.address,
                address: returnedPlace.street,
                city: returnedPlace.city,
                state: returnedPlace.state,
                country: returnedPlace.country,
                latitude: returnedPlace.latitude,
                longitude: returnedPlace.longitude)
        }
    }
    
    @Published var selectedInterests: [Interest] = [] {
        didSet{
            editPost.interests = selectedInterests.map({ Interest in
                Components.Schemas.Interest(name: Interest.name, icon: Interest.icon, category: Interest.category)
            })
        }
    }
    
    //Participants View
    @Published var showParticipants = false
    
    //Date View
    @Published var from = Date().addingTimeInterval(900) {
        didSet{
            if to < from.addingTimeInterval(599) {
                to = from.addingTimeInterval(600)
            }
        }
    }
    @Published var to = Date().addingTimeInterval(4500)
    @Published var isDate = true
    @Published var dateTimeSettings = 0 {
        didSet{
            setDate()
        }
    }
    @Published var showTimeSettings: Bool = false
    @Published var isInit: Bool = true
    
}

// Photo
extension EditEventViewModel {
    func setDate() {
        if dateTimeSettings == 0 {
            editPost.fromDate = nil
            editPost.toDate = nil
        } else if dateTimeSettings == 1 {
            editPost.fromDate = from
            editPost.toDate = nil
        } else {
            editPost.fromDate = from
            editPost.toDate = to
        }
    }
    
    func fetchPostData(post: Components.Schemas.PostResponseDto) {
        editPost = post
        initialPost = post
        
        if let fromDate = post.fromDate, let toDate = post.toDate {
            from = fromDate
            to = toDate
            dateTimeSettings = 2
        } else if let fromDate = post.fromDate {
            from = fromDate
            dateTimeSettings = 1
        } else {
            dateTimeSettings = 0
        }
        
        description = post.description ?? ""
        selectedInterests = post.interests.map({ interest in
            Interest(name: interest.name, icon: interest.icon, category: interest.category)
        })
    }

    
    func convertToPatchPost(post: Components.Schemas.PostResponseDto) -> Components.Schemas.PatchPostDto {
        
        var fromDate: Date?
        var toDate: Date?
        
        if dateTimeSettings == 1 {
            fromDate = from
            toDate = nil
        } else if dateTimeSettings == 2 {
            fromDate = from
            toDate = to
        } else {
            fromDate = nil
            toDate = nil
        }
        
        let post = Components.Schemas.PatchPostDto(
            title: post.title,
            images: post.images,
            description: post.description,
            maximumPeople: post.maximumPeople,
            location: post.location,
            interests: post.interests,
            toDate: toDate,
            accessibility: .init(rawValue: post.accessibility.rawValue) ?? .PUBLIC,
            fromDate: fromDate
        )
        
        return post
    }
}
