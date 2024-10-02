import ClusterMap
import SwiftUI
import MapKit
//
//struct ExampleAnnotation: Identifiable, CoordinateIdentifiable, Hashable {
//    var id = UUID()
//    var postID: String
//    var image: String
//    var name: String
//    var coordinate: CLLocationCoordinate2D
//}
//
//struct ExampleClusterAnnotation: Identifiable {
//    var id = UUID()
//    var postID: String
//    var image: String
//    var coordinate: CLLocationCoordinate2D
//    var count: Int
//}
//
//
class DataSource: ObservableObject {
    @Published var clusterManager = ClusterManager<MapAnnotation>()
    
    @Published var annotations: [MapAnnotation] = []
    @Published var clusters: [MapClusterAnnotation] = []
    
    @Published var mapSize: CGSize = .zero
    @Published var currentRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    func addAnnotations(posts: [Components.Schemas.PostResponseDto]) async {
        let points: [MapAnnotation] = posts.map { post in
            return .init(postID: post.id, image: post.images[0], name: post.title, coordinate:  CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude))
        }
        await clusterManager.add(points)
        await reloadAnnotations()
    }
    
//    func addAnnotations() async {
//        let points: [ExampleAnnotation] = [.init(postID: "1", image: "top", name: "top", coordinate:  CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683)), .init(postID: "1", image: "top", name: "top", coordinate:  CLLocationCoordinate2D(latitude: 34.053235, longitude: -118.243683))
//       ]
//        await clusterManager.add(points)
//        await reloadAnnotations()
//    }
    
    func removeAnnotations() async {
        await clusterManager.removeAll()
        await reloadAnnotations()
    }
    
    func reloadAnnotations() async {
        async let changes = clusterManager.reload(mapViewSize: mapSize, coordinateRegion: currentRegion)
        await applyChanges(changes)
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
}

