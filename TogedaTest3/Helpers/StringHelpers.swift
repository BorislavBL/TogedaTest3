//
//  StringHelpers.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 22.01.24.
//

import Foundation

func interestsOrder(_ interests: [Interest]) -> String {
    var text = ""
    for i in interests.indices {
        if i < 3 {
            text += "\(interests[i].icon) \(interests[i].name) "
        }
    }
    
    return text
}

func locationCityAndCountry(_ location: baseLocation) -> String {
    var locationComponents = [String]()
    
    if let city = location.city {
        locationComponents.append(city)
    } else if let state = location.state {
        locationComponents.append(state)
    }
    if let country = location.country {
        locationComponents.append(country)
    }
    
    return locationComponents.joined(separator: ", ")
}

func locationAddress(_ location: baseLocation) -> String {
    var locationComponents = [String]()
    
    if let street = location.address {
        locationComponents.append(street)
    }
    if let city = location.city {
        locationComponents.append(city)
    }
    if let state = location.state {
        locationComponents.append(state)
    }
    if let country = location.country {
        locationComponents.append(country)
    }
    
    return locationComponents.joined(separator: ", ")
}
