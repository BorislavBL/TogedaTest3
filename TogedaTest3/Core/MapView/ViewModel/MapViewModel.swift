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
        span: MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8)
    ))
    
    @Published var mapSelection: String?
    @Published var showPostView: Bool = false
    @Published var selectedPost: Components.Schemas.PostResponseDto = MockPost
    
    @Published var visibleRegion: MKCoordinateRegion?
    @Published private var isFetchingData = false
    @Published private var throttlingTimer: Timer?
    
    // New properties for tracking changes
    @Published private var previousCenter: CLLocationCoordinate2D?
    @Published private var previousZoomLevel: CLLocationDegrees?
    
    @Published private var significantChangeOccurred = false
    @Published var isActionTriggered = false
    
    // Function to detect significant map changes
    func hasSignificantChange(newRegion: MKCoordinateRegion) -> Bool {
        guard let previousCenter = previousCenter, let previousZoomLevel = previousZoomLevel else {
            // Initialize previous values on the first run
            self.previousCenter = newRegion.center
            self.previousZoomLevel = newRegion.span.latitudeDelta
            return false
        }
        
        let centerThreshold: CLLocationDistance = 5000 // meters
        let zoomOutThreshold: CLLocationDegrees = 0.02  // threshold for zoom out
        
        let centerDistance = CLLocation(latitude: previousCenter.latitude, longitude: previousCenter.longitude)
            .distance(from: CLLocation(latitude: newRegion.center.latitude, longitude: newRegion.center.longitude))
        
        let isZoomOutSignificant = newRegion.span.latitudeDelta - previousZoomLevel > zoomOutThreshold
        let isCenterShiftSignificant = centerDistance > centerThreshold
        
        if isZoomOutSignificant || isCenterShiftSignificant {
            // Update the previous values
            self.previousCenter = newRegion.center
            self.previousZoomLevel = newRegion.span.latitudeDelta
            
            // Mark that a significant change has occurred
            significantChangeOccurred = true
            return true
        }
        
        return false
    }
    
    func fetchEvents(region: MKCoordinateRegion) {        
        // Perform the API call asynchronously
        Task {
            defer {
                DispatchQueue.main.async {self.isActionTriggered = false}
            } // Reset flag when done
            try await getCurrentAreaPosts(region: region)
        }
    }
    
    
    private var stationaryTimer: Timer?

    // Function to start or reset the stationary timer
     func resetStationaryCheckTimer(region: MKCoordinateRegion) {
         // Invalidate any existing timer to reset it
         stationaryTimer?.invalidate()
         
         // Start a new timer for 5 seconds of inactivity
         stationaryTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
             guard let self = self else { return }
             if self.significantChangeOccurred && !self.isActionTriggered {
                 self.isActionTriggered = true // Mark as triggered to prevent repeated actions
                 self.fetchEvents(region: region) // Trigger the fetch function
             }
         }
     }
    
    // Optional function to stop tracking if needed
    func stopStationaryCheck() {
         stationaryTimer?.invalidate()
         significantChangeOccurred = false
         isActionTriggered = false
     }
    
    
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
        print("serach for posts triggered")
        
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

