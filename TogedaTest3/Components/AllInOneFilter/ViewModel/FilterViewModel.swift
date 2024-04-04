//
//  FilterViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import MapKit

class FilterViewModel: ObservableObject {
    @Published var showAllFilter: Bool = false
    @Published var searchText: String = ""
    @Published var returnedPlace = Place(mapItem: MKMapItem())
    @Published var isCurrentLocation = true
    
    @Published var selectedTimeFilter: String = "Anytime"
    var timeFilterOptions: [String] = ["Anytime", "Today", "Tomorrow", "This Week", "This Month", "This Year", "Custom"]
    
    @Published var from = Date() {
        didSet{
            selectedTimeFrame = timeToString()
        }
    }
    @Published var to = Date() {
        didSet{
            selectedTimeFrame = timeToString()
        }
    }
    @Published var selectedTimeFrame = "Custom Time"
    
    @Published var selectedSortFilter: String = "Relevance"
    var sortFilterOptions: [String] = ["Relevance", "Date"]
    
    @Published var sliderValue: Int = 300
    
    @Published var selectedCategories: [Category] = []
    var categories: [Category] = Category.Categories
    
    @Published var selectedType = "All"
    let types: [String] = ["All", "Events", "Groups", "Challenges", "Friends"]
    
    func resetFilter() {
        self.searchText = ""
        self.isCurrentLocation = true
        self.returnedPlace = Place(mapItem: MKMapItem())
        self.selectedTimeFilter = "Anytime"
        self.sliderValue = 300
        self.selectedSortFilter = "Relevance"
        self.selectedCategories = []
    }
    
    func timeToString() -> String {
        let dateFrom = formatDateToDayAndMonthString(date: from)
        let dateTo = formatDateToDayAndMonthString(date: to)
        if from == to {
            return dateFrom
        } else {
            return "\(dateFrom) -> \(dateTo)"
        }
    }

}
