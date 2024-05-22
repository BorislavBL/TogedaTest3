//
//  LocationManager.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.09.23.
//

import SwiftUI
import MapKit

class LocationManager: NSObject, ObservableObject {
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion()
    
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var showLocationServicesView: Bool = false
    
    private let locationManager = CLLocationManager()
    
    override init() {
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            showLocationServicesView = true
        case .denied:
            showLocationServicesView = true
        case .authorizedAlways:
            showLocationServicesView = false
        case .authorizedWhenInUse:
            showLocationServicesView = false
            locationManager.requestAlwaysAuthorization()
        default:
            print("default")
        }
    }
    
    
    func stopLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func requestAuthorization(){
       locationManager.desiredAccuracy = kCLLocationAccuracyBest
       locationManager.delegate = self
        
       if authorizationStatus == .notDetermined{
           locationManager.requestWhenInUseAuthorization()
       }
       else if authorizationStatus == .denied{
           showLocationServicesView = true
       }
        locationManager.startUpdatingLocation()
   }
    
    func setLocation(cameraPosition: Binding<MapCameraPosition>, span: CLLocationDegrees) {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        if let userLocation = locationManager.location?.coordinate {
            cameraPosition.wrappedValue = .region(MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
            ))
        }
    }
    
}

extension LocationManager: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !locations.isEmpty else { return }
        guard let location = locations.last else {return}
        self.location = location
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
//        locationManager.stopUpdatingLocation()
    }
    
    
}
