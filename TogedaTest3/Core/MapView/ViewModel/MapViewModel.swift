//
//  MapViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 23.09.23.
//



import SwiftUI
import MapKit
import Combine

class MapViewModel: ObservableObject{
    @Published var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    ))
    
    @Published var mapSelection: Components.Schemas.PostResponseDto?
    @Published var showPostView: Bool = false
    @Published var selectedPost: Components.Schemas.PostResponseDto = MockPost
    
    @Published var visibleRegion: MKCoordinateRegion?
    
    @Published var searchText: String = ""
    
    @Published var mapPosts: [Components.Schemas.PostResponseDto] = []
    
    @Published var searchedPosts: [Components.Schemas.PostResponseDto] = []
    @Published var lastSearchedPage: Bool = true
    @Published var searchedPage: Int32 = 0
    @Published var searchSize: Int32 = 15
    var cancellable: AnyCancellable?
    
    func searchPosts() async throws{
        Task{
            if let response = try await APIClient.shared.searchEvent(
                searchText: searchText,
                page: searchedPage,
                size: searchSize,
                askToJoin: false
            )
            {
                
                DispatchQueue.main.async { [weak self] in
                    self?.searchedPosts += response.data
                    self?.lastSearchedPage = response.lastPage
                    self?.searchedPage += 1
                }
            }
        }
    }
    
    func startSearch() {
        cancellable = $searchText
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { value in
                if !value.isEmpty {
                    print("Searching...")
                    self.toDefault()
                    Task{
                        try await self.searchPosts()
                    }
                } else {
                    print("Not Searching...")
                    self.toDefault()
                }
            })
    }
    
    func toDefault() {
        self.searchedPosts = []

        self.searchedPage = 0
        self.lastSearchedPage = true
    }
    
    func stopSearch() {
        cancellable = nil
    }
    
    func getCurrentAreaPosts(region: MKCoordinateRegion) async throws {
        Task{
            if let response = try await APIClient.shared.getMapEvents(
                centerLatitude: region.center.latitude,
                centerLongitude: region.center.longitude,
                spanLatitudeDelta: region.span.latitudeDelta,
                spanLongitudeDelta: region.span.longitudeDelta,
                page: 0,
                size: 25
            ) {

                DispatchQueue.main.async{
                    self.mapPosts = response.data
                }
            }
        }
    }
    
}

