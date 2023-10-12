//
//  LocationManager.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.09.23.
//

import Foundation
import MapKit

class LocationManager: NSObject, ObservableObject {
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion()
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !locations.isEmpty else { return }
        guard let location = locations.last else {return}
        self.location = location
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        locationManager.stopUpdatingLocation()
    }
}
