//
//  RegistrationLocationView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 20.12.23.
//

import SwiftUI
import MapKit

struct RegistrationLocationView: View {
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var keyIsFocused: Bool
    @Environment(\.dismiss) var dismiss
    @State private var displayError: Bool = false
    @State private var isActive: Bool = false
    
    @ObservedObject var vm: RegistrationViewModel
    @StateObject var locationVM = LocationPickerViewModel(searchType: .cityAndCountry)
    @ObservedObject var photoVM: PhotoPickerViewModel

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
                            .submitLabel(.next)
                            .onSubmit {
                                if vm.returnedPlace.name == "Unknown Location" || locationVM.searchText.isEmpty {
                                    displayError.toggle()
                                } else {
                                    isActive = true
                                }
                            }
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
                                vm.returnedPlace = place
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading )
                    }
                    
                
            }
            .frame(maxWidth: .infinity, alignment: .leading )
            .padding(16)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .cornerRadius(10.0)
            
            if displayError && vm.returnedPlace.name == "Unknown Location" && locationVM.searchText.isEmpty {
                WarningTextComponent(text: "Plese enter a location before you proceed.")
                    .padding(.vertical, 15)
            }
            
            Spacer()
            
            Button{
                isActive = true
            } label:{
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .cornerRadius(10)
                    .fontWeight(.semibold)
            }
            .disableWithOpacity(vm.returnedPlace.name == "Unknown Location" || locationVM.searchText.isEmpty)
            .onTapGesture {
                if vm.returnedPlace.name == "Unknown Location" || locationVM.searchText.isEmpty {
                    displayError.toggle()
                }
            }
            
        }
        .animation(.easeInOut(duration: 0.6), value: keyIsFocused)
        .padding(.horizontal)
        .toolbar{
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardToolbarItems()
            }
        }
        .onAppear(){
            keyIsFocused = true
        }
        .padding(.vertical)
        .swipeBack()
        .navigationDestination(isPresented: $isActive, destination: {
            RegistrationOccupationView(vm: vm, photoVM: photoVM)
        })
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
    RegistrationLocationView(vm: RegistrationViewModel(), photoVM: PhotoPickerViewModel(s3BucketName: .user, mode: .normal))
    
}
