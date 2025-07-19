//
//  EditProfileLocationView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 20.12.23.
//

import SwiftUI
import MapKit

struct EditProfileLocationView: View {
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var keyIsFocused: Bool
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var editProfileVM: EditProfileViewModel
    @StateObject var locationVM = LocationPickerViewModel(searchType: .cityWithCountry)
    @State var showCancelButton: Bool = false
    @State var isCurrentLocation: Bool = true
    
    var body: some View {
        VStack {
            Text("Where are you from?")
                .multilineTextAlignment(.center)
                .font(.title).bold()
                .padding(.top, 20)

            VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        
                        TextField("Search", text: $locationVM.searchText)
                            .foregroundColor(.primary)
                            .autocorrectionDisabled()
                            .focused($keyIsFocused)
                            .bold()
                        
                    }
                    .foregroundColor(.secondary)
                
                    

                    if !locationVM.searchText.isEmpty && keyIsFocused {
                        
                        ForEach(locationVM.places, id: \.id){ place in
                            VStack(alignment: .leading) {
                                HStack{
                                    Image(systemName: "mappin.circle")
                                        .imageScale(.medium)
                                    Text(place.addressCountry)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    
                                }
                            }
                            .onTapGesture {
                                UIApplication.shared.endEditing(true)
                                locationVM.searchText = place.addressCountry
                                showCancelButton = false
                                editProfileVM.returnedPlace = place
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading )
                    }
                    
                
            }
            .frame(maxWidth: .infinity, alignment: .leading )
            .padding(16)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .cornerRadius(10.0)
            
            Text("Please enter both a city and a country (e.g. \"London, United Kingdom\").")
                .multilineTextAlignment(.leading)
                .bold()
                .foregroundStyle(.gray)
                .padding(.vertical, 8)
            
            
            Spacer()
            
            
        }
        .animation(.easeInOut(duration: 0.6), value: keyIsFocused)
        .padding(.horizontal)
        .toolbar{
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardToolbarItems()
            }
        }
        .swipeBack()
        .padding(.vertical)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .frame(width: 35, height: 35)
                .background(Color(.tertiarySystemFill))
                .clipShape(Circle())
        })
    }

    
    var foregroundColor: Color {
        if colorScheme == .dark {
            return Color(.white)
        } else {
            return Color(.black)
        }
    }
    
    var backgroundColor: Color {
        if colorScheme == .dark {
            return Color(.systemGray5)
        } else {
            return Color(.systemGray6)
        }
    }
}
#Preview {
    EditProfileLocationView(editProfileVM: EditProfileViewModel())
}
