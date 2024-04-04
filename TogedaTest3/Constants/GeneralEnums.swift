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
