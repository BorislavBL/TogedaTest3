//
//  General.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 17.03.25.
//

import SwiftUI

func UserToMiniUser(user: Components.Schemas.UserInfoDto) -> Components.Schemas.MiniUser {
    return .init(id: user.id, firstName: user.firstName, lastName: user.lastName, profilePhotos: user.profilePhotos, occupation: user.occupation, location: user.location, birthDate: user.birthDate, isDeleted: user.isDeleted, userRole: .init(rawValue: user.userRole.rawValue) ?? .NORMAL)
}

func filterToTwoDecimals(_ input: String) -> String {
    let components = input.components(separatedBy: CharacterSet(charactersIn: ",."))
    guard components.count <= 2 else {
        // Too many decimal separators — remove the last input
        return String(input.dropLast())
    }

    var beforeDecimal = components[0]
    var afterDecimal = components.count > 1 ? components[1] : ""

    if afterDecimal.count > 2 {
        afterDecimal = String(afterDecimal.prefix(2))
    }

    return afterDecimal.isEmpty ? beforeDecimal : "\(beforeDecimal).\(afterDecimal)"
}

func interestColor(for category: String) -> Color {
    switch category.lowercased() {
    case "sport", "health":
        return .green
    case "extreme":
        return .red
    case "social", "business":
        return .cyan
    case "entertainment":
        return .orange
    case "technology", "technologies", "education":
        return .blue
    case "hobby":
        return .purple
    default:
        return .gray
    }
}
