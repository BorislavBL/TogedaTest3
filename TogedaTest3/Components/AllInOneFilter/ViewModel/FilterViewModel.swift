//
//  FilterViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import MapKit

enum FeedType {
    case events
    case clubs
    case friends
    
    var rawValue: String {
        switch self{
        case .events:
            return "Events"
        case .clubs:
            return "Clubs"
        case .friends:
            return "Friends"
        }
    }
}

class FilterViewModel: ObservableObject {
    @Published var showAllFilter: Bool = false
    @Published var searchText: String = ""
    @Published var returnedPlace = Place(mapItem: MKMapItem())
    @Published var isCurrentLocation = true
    
    @Published var selectedTimeFilter: TimeFilter = .timeFilterOptions[0]
    //["Anytime", "Today", "Tomorrow", "This Week", "This Month", "This Year", "Custom"]
    
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
    
    @Published var selectedSortFilter: String = "Location"
    var sortFilterOptions: [String] = ["Location", "Newest"]
    
    @Published var noDistanceLimit: Bool = true {
        didSet{
            if noDistanceLimit {
                sliderValue = 3000000
            } else {
                sliderValue = 300
            }
        }
    }
    @Published var sliderValue: Int = 3000000
    
    @Published var selectedCategories: [Category] = []
    var categories: [Category] = Category.Categories
    
    @Published var selectedType: FeedType = .events
    let types: [FeedType] = [.events, .clubs, .friends]
    
    @Published var updateEvents = false
    @Published var updateClubs = false
    @Published var updateActivity = false
    
    func resetFilter() {
        self.searchText = ""
        self.isCurrentLocation = true
        self.selectedTimeFilter = .timeFilterOptions[0]
        self.noDistanceLimit = true
        self.sliderValue = 300
        self.selectedSortFilter = "Location"
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


