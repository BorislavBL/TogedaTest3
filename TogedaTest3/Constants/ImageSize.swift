//
//  ImageSize.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.11.23.
//

import Foundation

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
