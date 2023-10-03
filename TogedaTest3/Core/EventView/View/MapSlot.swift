//
//  MapSlot.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 19.09.23.
//

import SwiftUI
import MapKit

struct MapSlot: View {
    let locations: [Location]
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), latitudinalMeters: 1000, longitudinalMeters: 1000))
    
    var body: some View {
        Map(position: $cameraPosition){
            Marker("Test", coordinate: locations[0].coordinate)
                .tint(.black)
        }
            .allowsHitTesting(false)
            .frame(height: 300)
            .cornerRadius(20)
    }
}

struct MapSlot_Previews: PreviewProvider {
    static var previews: some View {
        MapSlot(locations: [Location(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))])
    }
}

//        Map(
//            coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))),
//            annotationItems: locations) { location in
//                MapMarker(coordinate: location.coordinate, tint: .black)
//            }
