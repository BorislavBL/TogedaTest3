//
//  LocationHelper.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 27.09.23.
//

import Foundation
import MapKit
import SwiftUI


//func reverseGeocode(coordinate: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
//    let geocoder = CLGeocoder()
//    let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//
//    geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
//        if let error = error {
//            print("Reverse geocoding error: \(error)")
//            completion(nil)
//            return
//        }
//
//        if let placemark = placemarks?.first {
//            let locality = placemark.locality ?? ""
//            let administrativeArea = placemark.administrativeArea ?? ""
//            let country = placemark.country ?? ""
//            completion("\(country), \(administrativeArea), \(locality)")
//        } else {
//            completion(nil)
//        }
//    }
//}

func reverseGeocode(coordinate: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
    let geocoder = CLGeocoder()
    let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

    geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
        if let error = error {
            print("Reverse geocoding error: \(error)")
            completion(nil)
            return
        }

        if let placemark = placemarks?.first {
            let street = placemark.thoroughfare ?? ""
            let locality = placemark.locality ?? ""
//            let administrativeArea = placemark.administrativeArea ?? ""
            let country = placemark.country ?? ""
            
            // Construct the address string based on availability of each component
            var address = ""
            if !street.isEmpty { address += street + ", " }
            if !locality.isEmpty { address += locality + ", " }
//            if !administrativeArea.isEmpty { address += administrativeArea + ", " }
            if !country.isEmpty { address += country }

            // Remove trailing comma and space if they exist
            if address.hasSuffix(", ") {
                address.removeLast(2)
            }

            completion(address)
        } else {
            completion(nil)
        }
    }
}

func isLocationInsideVisibleRegion(latitude: Double, longitude: Double, region: MKCoordinateRegion) -> Bool {
    let minLatitude = region.center.latitude - (region.span.latitudeDelta / 2.0)
    let maxLatitude = region.center.latitude + (region.span.latitudeDelta / 2.0)
    let minLongitude = region.center.longitude - (region.span.longitudeDelta / 2.0)
    let maxLongitude = region.center.longitude + (region.span.longitudeDelta / 2.0)
    
    return latitude >= minLatitude &&
           latitude <= maxLatitude &&
           longitude >= minLongitude &&
           longitude <= maxLongitude
}

func mapItem(from placemark: CLPlacemark) -> MKMapItem {
    let mkPlacemark = MKPlacemark(placemark: placemark)
    return MKMapItem(placemark: mkPlacemark)
}

func findLocationDetails(location: CLLocation?, returnedPlace: Binding<Place>) {
    guard let location = location else { return }
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
        if let error = error {
            print("Error reverse geocoding: \(error.localizedDescription)")
            
        } else if let firstPlacemark = placemarks?.first {
            returnedPlace.wrappedValue = Place(mapItem: mapItem(from: firstPlacemark))
        } else {
            print("else")
        }
    }
}
