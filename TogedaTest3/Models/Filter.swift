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

struct TimeFilter: Hashable{
    let name: String
    let from: Date?
    let to: Date?
    
    static var timeFilterOptions: [TimeFilter] = [
        .init(name: "Anytime", from: nil, to: nil),
        .init(name: "Today", from: Date(), to: Date().addingTimeInterval(60 * 60 * 24)),
        .init(name: "Tomorrow", from: Date(), to: Date().addingTimeInterval(60 * 60 * 24 * 2)),
        .init(name: "This Week", from: Date(), to: Date().addingTimeInterval(60 * 60 * 24 * 7)),
        .init(name: "This Month", from: Date(), to: Date().addingTimeInterval(60 * 60 * 24 * 30)),
        .init(name: "This Year", from: Date(), to: Date().addingTimeInterval(60 * 60 * 24 * 365)),
        .init(name: "Custom", from: Date(), to: Date().addingTimeInterval(60 * 15)),
    ]
}
