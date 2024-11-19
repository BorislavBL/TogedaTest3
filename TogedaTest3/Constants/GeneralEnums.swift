//
//  GeneralEnums.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 5.03.24.
//

import Foundation
import SwiftUI


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

enum CommodityColor {
    case gold
    case silver
    case platinum
    case bronze
    var colors: [Color] {
        switch self {
        case .gold: return [ Color(hex: 0xDBB400),
                             Color(hex: 0xEFAF00),
                             Color(hex: 0xF5D100),
                             Color(hex: 0xF5D100),
                             Color(hex: 0xD1AE15),
                             Color(hex: 0xDBB400),
        ]
            
        case .silver: return [ Color(hex: 0x7d7d7d),
                               Color(hex: 0x7D7D7A),
                               Color(hex: 0xB3B6B5),
                               Color(hex: 0x8E8D8D),
                               Color(hex: 0xB3B6B5),
                               Color(hex: 0xA1A2A3),
        ]
            
        case .platinum: return [ Color(hex: 0x000000),
                               Color(hex: 0x444444),
                               Color(hex: 0x000000),
                               Color(hex: 0x444444),
                               Color(hex: 0x111111),
                               Color(hex: 0x000000),
        ]
            
        case .bronze: return [ Color(hex: 0x804A00),
                               Color(hex: 0x9C7A3C),
                               Color(hex: 0xB08D57),
                               Color(hex: 0x895E1A),
                               Color(hex: 0x804A00),
                               Color(hex: 0xB08D57),
        ]}
    }
    
    var linearGradient: LinearGradient
    {
        return LinearGradient(
            gradient: Gradient(colors: self.colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension Color {
    init(hex: Int, alpha: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
