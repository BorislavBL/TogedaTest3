//
//  Location.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation
import MapKit

struct Location: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

//struct Place: Identifiable {
//    let id: String
//    let name: String
//    let coordinate: CLLocationCoordinate2D
//}
