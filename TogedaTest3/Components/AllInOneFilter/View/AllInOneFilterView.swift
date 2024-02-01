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
    @StateObject var filterVM = FilterViewModel()
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 25 ){
                Text("Filters")
                    .font(.title)
                    .bold()
                    
                
                VStack(alignment: .leading, spacing: 16){
                    Text("Location")
                        .font(.body)
                        .bold()
                    
                    LocationPickerFilterView(returnedPlace: $filterVM.returnedPlace, isCurrentLocation: $filterVM.isCurrentLocation)
                    
                }
                .padding(.top, 6)
                
                VStack(alignment: .leading, spacing: 16){
                    Text("Time")
                        .font(.body)
                        .bold()
                    
                    StandartFilterView(selectedFilter: $filterVM.selectedTimeFilter, filterOptions: filterVM.timeFilterOptions, image: Image(systemName: "calendar"))
                }
                
                VStack(alignment: .leading, spacing: 16){
                    Text("Sort")
                        .font(.body)
                        .bold()
                    
                    StandartFilterView(selectedFilter: $filterVM.selectedSortFilter, filterOptions: filterVM.sortFilterOptions, image: Image(systemName: "list.bullet"))
                }
                
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
                
                Button{
                    filterVM.searchText = ""
                    filterVM.isCurrentLocation = true
                    filterVM.returnedPlace = Place(mapItem: MKMapItem())
                    
                    filterVM.selectedTimeFilter = "Anytime"
                    
                    filterVM.sliderValue = 300
                    
                    filterVM.selectedSortFilter = "Personalised"
                    
                    filterVM.selectedCategories = []
                } label: {
                    Text("Reset")
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity, alignment: .center )
                }
                
            }
            .padding()
        }
        .scrollIndicators(.never)
        
    }
}

struct LocationPickerFilterView: View {
    @EnvironmentObject var locationManager: LocationManager
    @StateObject var allInOneVM = AllInOneFilterViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var returnedPlace: Place
    @State var showCancelButton: Bool = false
    @Binding var isCurrentLocation: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            if !returnedPlace.addressCountry.isEmpty && !isCurrentLocation {
                Button {
                    returnedPlace = Place(mapItem: MKMapItem())
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
                    
                    TextField("Search", text: $allInOneVM.searchText)
                        .foregroundColor(.primary)
                        .autocorrectionDisabled()
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up")
                    
                }
                .foregroundColor(.secondary)
                

                if !allInOneVM.searchText.isEmpty {
                    
                    ForEach(allInOneVM.places, id: \.id){ place in
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
                            allInOneVM.searchText = ""
                            showCancelButton = false
                            returnedPlace = place
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading )
                }
                
                
                if locationManager.authorizationStatus == .authorizedWhenInUse{
                    Divider()
                        .padding(.horizontal)
                    
                    Button {
                        locationManager.requestAuthorization()
                        findLocationDetails(location: locationManager.location, returnedPlace: $returnedPlace)
                        UIApplication.shared.endEditing(true)
                        allInOneVM.searchText = ""
                        isCurrentLocation = true
                        
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

struct SwiftUISlider: UIViewRepresentable {
    
    final class Coordinator: NSObject {
        // The class property value is a binding: It’s a reference to the SwiftUISlider
        // value, which receives a reference to a @State variable value in ContentView.
        var value: Binding<Int>
        
        // Create the binding when you initialize the Coordinator
        init(value: Binding<Int>) {
            self.value = value
        }
        
        // Create a valueChanged(_:) action
        @objc func valueChanged(_ sender: UISlider) {
            self.value.wrappedValue = Int(sender.value)
        }
    }
    
    var thumbColor: UIColor = .white
    var minTrackColor: UIColor?
    var maxTrackColor: UIColor?
    
    @Binding var value: Int
    
    func makeUIView(context: Context) -> UISlider {
        let slider = UISlider(frame: .zero)
        slider.thumbTintColor = thumbColor
        slider.minimumTrackTintColor = minTrackColor
        if let color = maxTrackColor {
            slider.maximumTrackTintColor = color
        }
        slider.value = Float(value)
        slider.maximumValue = Float(300)
        slider.minimumValue = Float(1)
        
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )
        
        return slider
    }
    
    func updateUIView(_ uiView: UISlider, context: Context) {
        // Coordinating data between UIView and SwiftUI view
        uiView.value = Float(self.value)
    }
    
    func makeCoordinator() -> SwiftUISlider.Coordinator {
        Coordinator(value: $value)
    }
}

#Preview {
    AllInOneFilterView()
        .environmentObject(LocationManager())
}
