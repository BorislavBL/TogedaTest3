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
    var timeFilterOptions: [String] = ["Now", "Today", "This Week", "This Month", "Next 6 Months", "This Year", "Anytime"]
    
    @Published var selectedSortFilter: String = "Personalised"
    var sortFilterOptions: [String] = ["Personalised", "Trending", "Newest", "Oldest"]
    
    @Published var sliderValue: Int = 300
    
    @Published var selectedCategories: [String] = []
    var categories: [String] = ["🏃‍♂️ Sport", "Adventure", "Educational", "Social", "Casual", "Indoor", "Outdoor", "Grand", "Other"]
    
    @Published var selectedType = "All"
    let types: [String] = ["All", "Events", "Groups", "Challenges", "Friends"]
    

}
