//
//  FilterViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation

class FilterViewModel: ObservableObject {
    @Published var filters: [Filter] = [
        .init(id: NSUUID().uuidString, categoryName: "Time", isSelected: false, selectingCategory: "Any", selectedCategory: "Any",
              options: TimeOptions),
        .init(id: NSUUID().uuidString, categoryName: "Category", isSelected: false, selectingCategory: "Any", selectedCategory: "Any",
              options: CategoryOptions),
        .init(id: NSUUID().uuidString, categoryName: "Distance", isSelected: false, selectingCategory: "Any", selectedCategory: "Any",
              options: DistanceOptions),
        .init(id: NSUUID().uuidString, categoryName: "Type", isSelected: false, selectingCategory: "Any", selectedCategory: "Any",
              options: TypeOptions)
    ]
    
    @Published var selectedFilter: Filter?
    @Published var filterIsSelected: Bool = false
    @Published var selectedFilterIndex: Int = 0
    
    func updateFilterSheetPresentation() {
        filterIsSelected = filters.contains(where: { $0.isSelected })
    }
    
    @Published var showAllFilter: Bool = false
    
//    var filterIsSelected: Bool {
//        return filters.contains(where: { $0.isSelected })
//    }

}
