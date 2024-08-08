//
//  Location.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation
import MapKit

struct baseLocation: Hashable, Codable {
    var name: String
    var address: String?
    var city: String?
    var state: String?
    var country: String?
    var latitude: Double
    var longitude: Double
}

struct Place: Identifiable{
    var id = UUID().uuidString
    var mapItem: MKMapItem
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
    
    var name: String {
        self.mapItem.name ?? ""
    }
    
    var street: String? {
        var address = ""
        address = self.mapItem.placemark.subThoroughfare ?? "" // address #
        if let street = self.mapItem.placemark.thoroughfare {
            address = address.isEmpty ? street : "\(address) \(street)"
        }
        
        if address.isEmpty {
            return nil
        } else {
            return address
        }
    }
    
    var city: String? {
        if let city = self.mapItem.placemark.locality {
            return city
        } else{
            return nil
        }
    }
    
    var state: String? {
        if let state = self.mapItem.placemark.administrativeArea {
            return state
        } else{
            return nil
        }
    }

    var country: String? {
        if let country = self.mapItem.placemark.country {
            return country
        } else{
            return nil
        }
    }
    
    var address: String {
        let placemark = self.mapItem.placemark
        var cityAndState = ""
        var address = ""
        
        if let city = placemark.locality {
            if let state = placemark.administrativeArea {
                if city != state {
                    cityAndState = "\(city), \(state)"
                } else {
                    cityAndState = city
                }
            } else {
                cityAndState = city
            }
        } else if let state = placemark.administrativeArea {
            cityAndState = state
        }
        
        address = placemark.subThoroughfare ?? "" // address #
        
        if let street = placemark.thoroughfare {
            address = address.isEmpty ? street : "\(address) \(street)"
        }
        
        if address.trimmingCharacters(in: .whitespaces).isEmpty && !cityAndState.isEmpty {
            address = cityAndState
        } else {
            address = cityAndState.isEmpty ? address : "\(address), \(cityAndState)"
        }
        
        return address
    }

    
    var addressCountry: String {
        let placemark = self.mapItem.placemark
        var locationComponents = [String]()

        if let city = placemark.locality {
            if let state = placemark.administrativeArea {
                if city != state {
                    locationComponents.append(city)
                    locationComponents.append(state)
                } else {
                    locationComponents.append(city)
                }
            } else {
                locationComponents.append(city)
            }
        } else if let state = placemark.administrativeArea {
            locationComponents.append(state)
        }

        if let country = placemark.country {
            locationComponents.append(country)
        }
        
        return locationComponents.joined(separator: ", ")
    }

    
    var latitude: Double {
        self.mapItem.placemark.coordinate.latitude
    }
    
    var longitude: Double {
        self.mapItem.placemark.coordinate.longitude
    }
}
