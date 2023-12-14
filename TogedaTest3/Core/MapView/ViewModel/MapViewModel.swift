//
//  MapViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 23.09.23.
//



import SwiftUI
import MapKit

class MapViewModel: ObservableObject{
    @Published var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    ))
    
    @Published var mapSelection: Post?
    @Published var showPostView: Bool = false
    @Published var selectedPost: Post = Post.MOCK_POSTS[0]
    
    @Published var visibleRegion: MKCoordinateRegion?
    
    @Published var searchText: String = ""
    @Published var searchResults: [Post] = Post.MOCK_POSTS.filter{$0.accessability == Visabilities.Public}
    
    @Published var mapPosts: [Post] = Post.MOCK_POSTS.filter{$0.accessability == Visabilities.Public}
    
}

//
//struct UIMap: UIViewRepresentable {
//    
//    let mapView = MKMapView()
//    let locationManager = LocationManager()
//    
//    func makeUIView(context: Context) -> some UIView {
//        mapView.delegate = context.coordinator
//        mapView.isRotateEnabled = false
//        mapView.showsUserLocation = true
//        mapView.userTrackingMode = .follow
//        mapView.pointOfInterestFilter = .excludingAll
//        
//        return mapView
//    }
//    
//    func updateUIView(_ uiView: UIViewType, context: Context) {
//
//    }
//    
//    func makeCoordinator() -> MapCoordinator {
//        return MapCoordinator(parent: self)
//    }
//}
//
//extension UIMap {
//    class MapCoordinator: NSObject, MKMapViewDelegate {
//        let parent: UIMap
//        
//        init(parent: UIMap) {
//            self.parent = parent
//            super.init()
//        }
//        
//        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//            let region = MKCoordinateRegion(
//                center: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude),
//                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
//            
//            parent.mapView.setRegion(region, animated: true)
//        }
//        
//    }
//}
