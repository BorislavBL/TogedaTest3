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

func interestsOrder1(_ interests: [Components.Schemas.Interest]) -> String {
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

func locationCityAndCountry1(_ location: Components.Schemas.BaseLocation) -> String {
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

func locationAddress1(_ location: Components.Schemas.BaseLocation) -> String {
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

func convertCmToFeetAndInches(_ centimeters: String) -> String? {
    guard let cm = Double(centimeters) else { return nil }
    
    let totalInches = cm / 2.54
    let feet = Int(totalInches / 12)
    let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
    
    return "\(feet)' \(inches)\""
}
