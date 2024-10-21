//
//  LocationPicker.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 11.10.23.
//

import SwiftUI
import MapKit

struct LocationPicker: View {
    @EnvironmentObject var locationManager: LocationManager
    @StateObject var placeVM = LocationPickerViewModel(searchType: .all)
    @Environment(\.dismiss) private var dismiss
    @Binding var returnedPlace: Place
    @State var showCancelButton: Bool = false
    @State private var placemark: CLPlacemark?
    @State var isActive: Bool = false
    @Binding var isActivePrev: Bool
    
    var body: some View {
        VStack {
            CustomSearchBar(searchText: $placeVM.searchText, showCancelButton: $showCancelButton)
                .padding(.horizontal)
            
            if placeVM.searchText.isEmpty {
                
                if locationManager.authorizationStatus == .authorizedWhenInUse{
                    Button {
                        locationManager.requestCurrentLocation()
                        findLocationDetails(location: locationManager.location, returnedPlace: $returnedPlace) {
                            UIApplication.shared.endEditing(true)
                            placeVM.searchText = ""
                            showCancelButton = false
                            isActive = true
                        }
                        locationManager.stopLocation()

                    } label: {
                        Label {
                            Text("Use Current Location")
                                .font(.callout)
                        } icon: {
                            Image(systemName: "location.north.circle.fill")
                        }
                        .foregroundStyle(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading )
                    .padding()
                }
            } else {
                
                List(placeVM.places){ place in
                    HStack{
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading) {
                            Text(place.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            if !place.address.isEmpty {
                                Text(place.address)
                                    .font(.callout)
                            }
                        }
                    }
                    .onTapGesture {
                        UIApplication.shared.endEditing(true)
                        placeVM.searchText = ""
                        showCancelButton = false
                        returnedPlace = place
//                        dismiss()
                        isActive = true
                    }
                }
                .listStyle(.plain)
            }
            
        }
        .toolbar{
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardToolbarItems()
            }
        }
        .navigationTitle("Location")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .imageScale(.medium)
                .padding(.all, 8)
                .background(Color("main-secondary-color"))
                .clipShape(Circle())
        })
        .navigationDestination(isPresented: $isActive, destination: {
            ConfirmLocationMapView(returnedPlace: $returnedPlace, isActivePrev: $isActivePrev, isActive: $isActive)
//            TestView()
        })
        .padding(.vertical)
        .frame(maxHeight: .infinity, alignment: .top )
    }
}

#Preview {
    LocationPicker(returnedPlace: .constant(Place(mapItem: MKMapItem())), isActivePrev: .constant(true))
        .environmentObject(LocationManager())
}

