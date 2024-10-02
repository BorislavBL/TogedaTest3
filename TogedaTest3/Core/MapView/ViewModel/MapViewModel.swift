//
//  MapViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 23.09.23.
//



import SwiftUI
import MapKit
import Combine
import ClusterMap


struct MapAnnotation: Identifiable, CoordinateIdentifiable, Hashable {
    var id = UUID()
    var postID: String
    var image: String
    var name: String
    var coordinate: CLLocationCoordinate2D
}

struct MapClusterAnnotation: Identifiable {
    var id = UUID()
    var postID: String
    var image: String
    var name: String
    var coordinate: CLLocationCoordinate2D
    var count: Int
}

class MapViewModel: ObservableObject{
    @Published var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    ))
    
    @Published var mapSelection: String?
    @Published var showPostView: Bool = false
    @Published var selectedPost: Components.Schemas.PostResponseDto = MockPost
    
    @Published var visibleRegion: MKCoordinateRegion?
    
    @Published var searchText: String = ""
    
    @Published var mapPosts: [Components.Schemas.PostResponseDto] = []
    
//    @Published var searchedPosts: [Components.Schemas.PostResponseDto] = []
//    @Published var lastSearchedPage: Bool = true
//    @Published var searchedPage: Int32 = 0
//    @Published var searchSize: Int32 = 15
    
    @Published var places: [Place] = []
    
    var cancellable: AnyCancellable?
    
    @Published var clusterManager = ClusterManager<MapAnnotation>()
    
    @Published var annotations: [MapAnnotation] = []
    @Published var clusters: [MapClusterAnnotation] = []
    
    @Published var mapSize: CGSize = .zero
//    @Published var currentRegion: MKCoordinateRegion = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683),
//        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
//    )
    
    func addAnnotations(posts: [Components.Schemas.PostResponseDto]) async {
        await clusterManager.removeAll()
        let points: [MapAnnotation] = posts.map { post in
            return .init(postID: post.id, image: post.images[0], name: post.title, coordinate:  CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude))
        }
        await clusterManager.add(points)
        await reloadAnnotations()
    }
    
    func removeAnnotations() async {
        await clusterManager.removeAll()
        await reloadAnnotations()
    }
    
    func reloadAnnotations() async {
        if let region = visibleRegion {
            async let changes = clusterManager.reload(mapViewSize: mapSize, coordinateRegion: region)
            await applyChanges(changes)
        }
    }
    
    @MainActor
    private func applyChanges(_ difference: ClusterManager<MapAnnotation>.Difference) {
        for removal in difference.removals {
            switch removal {
            case .annotation(let annotation):
                annotations.removeAll { $0 == annotation }
            case .cluster(let clusterAnnotation):
                clusters.removeAll { $0.id == clusterAnnotation.id }
            }
        }
        for insertion in difference.insertions {
            switch insertion {
            case .annotation(let newItem):
                annotations.append(newItem)
            case .cluster(let newItem):
                clusters.append(MapClusterAnnotation(
                    id: newItem.id,
                    postID: newItem.memberAnnotations[0].postID,
                    image: newItem.memberAnnotations[0].image,
                    name: newItem.memberAnnotations[0].name,
                    coordinate: newItem.coordinate,
                    count: newItem.memberAnnotations.count
                ))
            }
        }
    }
    
//    func searchPosts() async throws{
//        Task{
//            if let response = try await APIClient.shared.searchEvent(
//                searchText: searchText,
//                page: searchedPage,
//                size: searchSize,
//                askToJoin: false
//            )
//            {
//                
//                DispatchQueue.main.async { [weak self] in
//                    self?.searchedPosts += response.data
//                    self?.lastSearchedPage = response.lastPage
//                    self?.searchedPage += 1
//                }
//            }
//        }
//    }
    
    func searchLocation(){
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let response = response else {
                print(":( ERROR: \(error?.localizedDescription ?? "Uknown Error")")
                return
            }
            
            self.places = response.mapItems.map(Place.init)
        }
    }
    
    func startSearch() {
        cancellable = $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { value in
                if !value.isEmpty {
                    print("Searching...")
//                    self.toDefault()
//                    Task{
//                        try await self.searchPosts()
//                    }
                    self.searchLocation()
                } else {
                    print("Not Searching...")
//                    self.toDefault()
                }
            })
    }
    
//    func toDefault() {
//        self.searchedPosts = []
//
//        self.searchedPage = 0
//        self.lastSearchedPage = true
//    }
    
    func stopSearch() {
        cancellable = nil
    }
    
    func searchForPost(id: String) -> Components.Schemas.PostResponseDto?{
        if let index = mapPosts.firstIndex(where: { post in
            if let id = mapSelection {
                return post.id == id
            } else {
                return false
            }
        }) {
            return self.mapPosts[index]
            
        } else {
            print("No index")
            return nil
        }
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
                
                await addAnnotations(posts: response.data)

                DispatchQueue.main.async{
                    self.mapPosts = response.data
                }
            }
        }
    }
    
}

