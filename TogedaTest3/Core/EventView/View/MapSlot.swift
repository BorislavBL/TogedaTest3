//
//  MapSlot.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 19.09.23.
//

import SwiftUI
import MapKit

struct MapSlot: View {
    let name: String
    let latitude: Double
    let longitude: Double
    
//    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), latitudinalMeters: 1000, longitudinalMeters: 1000))
    
    var body: some View {
        Button(action: {
            let url = URL(string: "maps://?saddr=&daddr=\(latitude),\(longitude)")
            if UIApplication.shared.canOpenURL(url!) {
                  UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
        }, label: {
            Map(initialPosition: .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), latitudinalMeters: 1000, longitudinalMeters: 1000))
            ){
                Marker(name, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    .tint(.black)
            }
                .allowsHitTesting(false)
                .frame(height: 300)
                .cornerRadius(20)        })
        
    }
}

struct MapSlot_Previews: PreviewProvider {
    static var previews: some View {
        MapSlot(name: "Test", latitude: 37.7749, longitude: -122.4194)
    }
}

//        Map(
//            coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))),
//            annotationItems: locations) { location in
//                MapMarker(coordinate: location.coordinate, tint: .black)
//            }
