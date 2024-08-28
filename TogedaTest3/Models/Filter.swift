//
//  Filter.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation

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

