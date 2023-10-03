//
//  LocationHelper.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 27.09.23.
//

import Foundation
import MapKit

func separateDateAndTime(from inputDate: Date) -> (date: String, time: String, weekday: String) {
    let calendar = Calendar.current

    // Check if the date is today or tomorrow
    let date: String
    if calendar.isDateInToday(inputDate) {
        date = "Today"
    } else if calendar.isDateInTomorrow(inputDate) {
        date = "Tomorrow"
    } else {
        // If not today or tomorrow, format the date as you desire
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        date = dateFormatter.string(from: inputDate)
    }

    // Format the time
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "HH:mm"
    let time = timeFormatter.string(from: inputDate)

    // Get the weekday
    let weekdayFormatter = DateFormatter()
    weekdayFormatter.dateFormat = "EEEE"
    let weekday = weekdayFormatter.string(from: inputDate)

    return (date, time, weekday)
}

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
