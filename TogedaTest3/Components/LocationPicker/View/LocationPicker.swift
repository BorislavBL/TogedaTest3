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
    @StateObject var placeVM = LocationPickerViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var returnedPlace: Place
    @State var showCancelButton: Bool = false
    @State private var placemark: CLPlacemark?
    
    var body: some View {
        VStack {
            CustomSearchBar(searchText: $placeVM.searchText, showCancelButton: $showCancelButton)
                .padding(.horizontal)
            
            if placeVM.searchText.isEmpty {
                
                if locationManager.authorizationStatus == .authorizedWhenInUse{
                    Button {
                        locationManager.requestAuthorization()
                        findLocationDetails(location: locationManager.location, returnedPlace: $returnedPlace)
                        UIApplication.shared.endEditing(true)
                        placeVM.searchText = ""
                        showCancelButton = false
                        dismiss()
                        
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
                    VStack(alignment: .leading) {
                        Text(place.name)
                            .font(.title2)
                        Text(place.address)
                            .font(.callout)
                    }
                    .onTapGesture {
                        UIApplication.shared.endEditing(true)
                        placeVM.searchText = ""
                        showCancelButton = false
                        returnedPlace = place
                        dismiss()
                    }
                }
                .listStyle(.plain)
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .imageScale(.medium)
                .padding(.all, 8)
                .background(Color("secondaryColor"))
                .clipShape(Circle())
        })
        .padding(.vertical)
        .frame(maxHeight: .infinity, alignment: .top )
    }
}

#Preview {
    LocationPicker(returnedPlace: .constant(Place(mapItem: MKMapItem())))
        .environmentObject(LocationManager())
}

