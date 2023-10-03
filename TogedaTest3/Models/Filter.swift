//
//  Filter.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation

struct Filter: Identifiable, Hashable {
    let id: String
    let categoryName: String
    var isSelected: Bool
    var selectingCategory: String
    var selectedCategory: String
    let options: [Option]
    
    mutating func setSelected(state: Bool) {
        isSelected = state
    }
}

struct Option: Identifiable, Hashable {
    let id: String
    let name: String
}

extension Filter {
    static var FILTERS: [Filter] = [
        .init(id: NSUUID().uuidString, categoryName: "Time", isSelected: false, selectingCategory: "Any", selectedCategory: "Any",
              options: TimeOptions),
        .init(id: NSUUID().uuidString, categoryName: "Category", isSelected: false, selectingCategory: "Any", selectedCategory: "Any",
              options: CategoryOptions),
        .init(id: NSUUID().uuidString, categoryName: "Distance", isSelected: false, selectingCategory: "Any", selectedCategory: "Any",
              options: DistanceOptions),
        .init(id: NSUUID().uuidString, categoryName: "Type", isSelected: false, selectingCategory: "Any", selectedCategory: "Any",
              options: TypeOptions)
    ]
}
