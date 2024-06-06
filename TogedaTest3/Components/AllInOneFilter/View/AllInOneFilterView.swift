//
//  AllInOneFilterView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 5.12.23.
//

import SwiftUI
import MapKit
import WrappingHStack

struct AllInOneFilterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var filterVM: FilterViewModel
    @EnvironmentObject var postVM: PostsViewModel
    
    var body: some View {
        VStack(spacing: 0){
            
            navbar()
            
            ScrollView{
                VStack(alignment: .leading, spacing: 25 ){
                    
                    VStack(alignment: .leading, spacing: 16){
                        Text("Time")
                            .font(.body)
                            .bold()
                        
                        TimeFilterView(vm: filterVM)
                    }
                    
                    VStack(alignment: .leading, spacing: 16){
                        Text("Sort")
                            .font(.body)
                            .bold()
                        
                        StandartFilterView(selectedFilter: $filterVM.selectedSortFilter, filterOptions: filterVM.sortFilterOptions, image: Image(systemName: "list.bullet"))
                    }
                    
                    VStack(alignment: .leading, spacing: 16){
                        Text("Location")
                            .font(.body)
                            .bold()
                        
                        LocationPickerFilterView(returnedPlace: $filterVM.returnedPlace, isCurrentLocation: $filterVM.isCurrentLocation)
                        
                    }
                    .padding(.top, 6)
                    
                    VStack(alignment: .leading, spacing: 16){
                        HStack{
                            Text("Distance")
                                .font(.body)
                                .bold()
                                
                            Spacer()
                            
                            Text("\(filterVM.sliderValue) km")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)

                        }
    //                    Slider(value: $sliderValue, in: 1...300, step: 1)
                        
                        SwiftUISlider(
                          thumbColor: UIColor(Color("blackAndWhite")),
                          minTrackColor: UIColor(Color("blackAndWhite")),
                          value: $filterVM.sliderValue
                        )
     
                    }
                    
                    VStack(alignment: .leading, spacing: 16){
                        HStack{
                            Text("Categories")
                                .font(.body)
                                .bold()
                                
                            Spacer()
                            
                            Text("\(filterVM.selectedCategories.count) selected")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)

                        }
                        
                        CategoryFilterView(selectedCategories: $filterVM.selectedCategories, categories: filterVM.categories)
                        
                    }
                    
                    Button {
                        Task{
                           try await postVM.applyFilter(
                            lat: filterVM.returnedPlace.latitude,
                            long: filterVM.returnedPlace.longitude,
                            distance: filterVM.sliderValue,
                            from: filterVM.selectedTimeFilter.from,
                            to: filterVM.selectedTimeFilter.to, 
                            categories: filterVM.selectedCategories.count > 0 ? filterVM.selectedCategories.map({ Category in
                                Category.name.lowercased()
                            }) : nil
                           )
                        }
                        
                        dismiss()
                    } label: {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .fontWeight(.semibold)
                        
                    }
                    .cornerRadius(10)
                    .padding(.top, 8)
                    
                }
                .padding()
            }
            .scrollIndicators(.never)
        .ignoresSafeArea(.keyboard)
        }
    }
    
    @ViewBuilder
    func navbar() -> some View {
        VStack{
            HStack{
                Button {
                    dismiss()
                } label:{
                    Text("Cancel")
                }
                
                Spacer()
                
                Text("Filters")
                    .font(.body)
                    .bold()
                
                Spacer()
                
                Button {
                    filterVM.resetFilter()
                } label:{
                    Text("Reset")
                }
            }
            
            Divider()
        }
        .padding([.horizontal, .top])
    }
}

struct LocationPickerFilterView: View {
    @EnvironmentObject var locationManager: LocationManager
    @StateObject var locationVM = LocationPickerViewModel(searchType: .cityAndCountry)
    @Environment(\.dismiss) private var dismiss
    @Binding var returnedPlace: Place
    @State var showCancelButton: Bool = false
    @Binding var isCurrentLocation: Bool
    @FocusState var focus: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            if !returnedPlace.addressCountry.isEmpty && !isCurrentLocation {
                Button {
                    returnedPlace = Place(mapItem: MKMapItem())
                    focus = true
                } label:{
                    HStack {
                        Image(systemName: "mappin.circle")
                            .imageScale(.medium)
                        Text(returnedPlace.addressCountry)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                            
                    }
                }
                
            } else if isCurrentLocation {
                Button {
                    returnedPlace = Place(mapItem: MKMapItem())
                    isCurrentLocation = false
                    focus = true
                } label: {
                    
                    HStack{
                        Image(systemName: "location.circle.fill")
                            .foregroundStyle(.blue)
                        
                        Text("Current Location")
                            .foregroundStyle(.blue)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading )
            } else {
                HStack {
                    Image(systemName: "magnifyingglass")
                    
                    TextField("Search", text: $locationVM.searchText)
                        .foregroundColor(.primary)
                        .autocorrectionDisabled()
                        .focused($focus)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up")
                    
                }
                .foregroundColor(.secondary)
                

                if !locationVM.searchText.isEmpty {
                    
                    ForEach(locationVM.places, id: \.id){ place in
                        VStack(alignment: .leading) {
                            HStack{
                                Image(systemName: "mappin.circle")
                                    .imageScale(.medium)
                                Text(place.name)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                            }
                            
                            HStack{
                                Image(systemName: "mappin.circle")
                                    .imageScale(.medium)
                                    .opacity(0.0)
                                Text(place.addressCountry)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.gray)
                                    .font(.callout)
                            }
                        }
                        .onTapGesture {
                            UIApplication.shared.endEditing(true)
                            locationVM.searchText = ""
                            showCancelButton = false
                            returnedPlace = place
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading )
                }
                
                
                if locationManager.authorizationStatus == .authorizedWhenInUse {
                    Divider()
                        .padding(.horizontal)
                    
                    Button {
//                        locationManager.requestAuthorization()
                        findLocationDetails(location: locationManager.location, returnedPlace: $returnedPlace){
                            UIApplication.shared.endEditing(true)
                            locationVM.searchText = ""
                            isCurrentLocation = true
                            focus = false
                        }
                        
                    } label: {
                        Label {
                            Text("Current Location")
                                .fontWeight(.semibold)
                        } icon: {
                            Image(systemName: "location.circle.fill")
                        }
                        .foregroundStyle(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading )
                }
            }
        }
        .onAppear(){
            findLocationDetails(location: locationManager.location, returnedPlace: $returnedPlace) {
                isCurrentLocation = true
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading )
        .padding(16)
        .background(Color(.tertiarySystemFill))
        .cornerRadius(10.0)
        .frame(maxHeight: .infinity, alignment: .top )
    }
}

struct StandartFilterView: View {
    @Binding var selectedFilter: String
    var filterOptions: [String]
    var image: Image
    @State var showOptions: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button{
                showOptions.toggle()
            } label: {
                HStack{
                    image
                    Text(selectedFilter)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Image(systemName: showOptions ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            
            if showOptions{
                ForEach(filterOptions, id: \.self){option in
                    Button{
                        selectedFilter = option
                        showOptions = false
                    } label:{
                        Text(option)
                            .fontWeight(.semibold)
                    }
                }
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading )
        .padding(16)
        .background(Color(.tertiarySystemFill))
        .cornerRadius(10.0)
        .frame(maxHeight: .infinity, alignment: .top )
    }
}

struct TimeFilterView: View {
    @State var showOptions: Bool = false
    @ObservedObject var vm: FilterViewModel
    @State var dateFormat = "Custom"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button{
                showOptions.toggle()
            } label: {
                HStack{
                    Image(systemName: "calendar")
                    if vm.selectedTimeFilter.name == "Custom" {
                        Text(vm.selectedTimeFrame)
                            .fontWeight(.semibold)
                    } else {
                        Text(vm.selectedTimeFilter.name)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    Image(systemName: showOptions ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            
            if showOptions{
                ForEach(TimeFilter.timeFilterOptions, id: \.self){option in
                    Button{
                        vm.selectedTimeFilter = option
                        if option.name != "Custom" {
                            showOptions = false
                        } else {
                            vm.selectedTimeFrame = vm.timeToString()
                        }
                    } label:{
                        Text(option.name)
                            .fontWeight(.semibold)
                    }
                }
                
                if vm.selectedTimeFilter.name == "Custom" {
                    HStack{
                        DatePicker("From", selection: $vm.from, in: Date()..., displayedComponents: [.date])
                            .fontWeight(.semibold)
                            .labelsHidden()
                        
                        Image(systemName: "arrow.right")
                        
                        DatePicker("To", selection: $vm.to, in: vm.from.addingTimeInterval(60 * 15)..., displayedComponents: [.date])
                            .fontWeight(.semibold)
                            .labelsHidden()
                    }
                }
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading )
        .padding(16)
        .background(Color(.tertiarySystemFill))
        .cornerRadius(10.0)
        .frame(maxHeight: .infinity, alignment: .top )
    }
}

struct CategoryFilterView: View {
    @Binding var selectedCategories: [Category]
    var categories: [Category]
    
    var body: some View {
        WrappingHStack(alignment: .topLeading, horizontalSpacing: 10, verticalSpacing: 16){
            ForEach(categories, id: \.self){ category in
                Button{
                    if selectedCategories.contains(category){
                        selectedCategories.removeAll(where:{ $0 == category})
                    } else {
                        selectedCategories.append(category)
                    }
                } label: {
                    if selectedCategories.contains(category){
                        Text("\(category.icon) \(category.name)")
                            .selectedTagTextStyle()
                            .selectedTagCapsuleStyle()
                    } else {
                        Text("\(category.icon) \(category.name)")
                            .normalTagTextStyle()
                            .normalTagCapsuleStyle()
                    }
                }
                
            }
        }
    }
}


#Preview {
    AllInOneFilterView(filterVM: FilterViewModel())
        .environmentObject(LocationManager())
        .environmentObject(PostsViewModel())
}
