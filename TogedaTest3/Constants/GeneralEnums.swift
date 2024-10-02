//
//  GeneralEnums.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 5.03.24.
//

import Foundation

enum Accessibility: String {
    case Public = "PUBLIC"
    case Private = "PRIVATE"
    
    var toString: String {
        switch self {
        case .Public:
            return "Public"
        case .Private:
            return "Private"
        }
    }
    
    var toCaptalizedStrings: String {
        switch self {
        case .Public:
            return "PUBLIC"
        case .Private:
            return "PRIVATE"
        }
    }
}

enum ImageSize {
    case xxSmall
    case xSmall
    case small
    case xMedium
    case medium
    case large
    
    
    var dimension: CGFloat {
        switch self {
        case .xxSmall:
            return 28
        case .xSmall:
            return 32
        case .small:
            return 40
        case .xMedium:
            return 50
        case .medium:
            return 60
        case .large:
            return 120
        }
    }
}

enum LoadingPhases {
    case isLoading
    case hasLoaded
}
