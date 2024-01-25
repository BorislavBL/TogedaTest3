//
//  CreateEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import MapKit

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @State var showExitSheet: Bool = false
    @State var displayWarnings: Bool = false
    @StateObject var ceVM = CreateEventViewModel()
    
    //PhotoPicker
    @StateObject var photoPickerVM = PhotoPickerViewModel()
    
    let descriptionPlaceholder = "Describe the purpose of your event. What activities are you planning? Mention any special guests who might be attending. Will there be food and drinks? Help attendees know what to expect."
    
    var body: some View {
        NavigationStack {
            VStack{
                ScrollView(showsIndicators: false){
                    VStack(alignment: .leading){
                        Text("Title:")
                            .foregroundStyle(.tint)
                        TextField("What event would you like to make?", text: $ceVM.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .onChange(of: ceVM.title) { oldValue, newValue in
                                if ceVM.title.count > 70 {
                                    ceVM.title = String(ceVM.title.prefix(70))
                                }
                            }
                    }
                    .createEventTabStyle()
                    .padding(.top)
                    
                    if titleEmpty {
                        WarningTextComponent(text: "Please write a title.")
                    } else if titleChartLimit {
                        WarningTextComponent(text: "The title has to be more than 5 characters long.")
                    }
                    
                    
                    NavigationLink {
                        DescriptionView(description: $ceVM.description, placeholder: descriptionPlaceholder)
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "square.and.pencil")
                                .imageScale(.large)
                            
                            
                            Text("Description")
                            
                            Spacer()
                            
                            Text(ceVM.description)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                        }
                        .createEventTabStyle()
                    }
                    
                    NavigationLink {
                        PhotoPickerView(photoPickerVM: photoPickerVM)
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "photo")
                                .foregroundStyle(.tint)
                            Text("Photos")
                                .foregroundStyle(.tint)
                            Spacer()
                            
                            if photoPickerVM.selectedImages.contains(where: {$0 != nil}) {
                                Text("Selected")
                                    .foregroundColor(.gray)
                            } else {
                                Text("Select")
                                    .foregroundStyle(.gray)
                            }
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundStyle(.gray)
                            
                            
                        }
                        .createEventTabStyle()
                        
                    }
                    
                    if noPhotos {
                        WarningTextComponent(text: "Please add photos.")
                        
                    }
                    
                    
                    NavigationLink {
                        LocationPicker(returnedPlace: $ceVM.returnedPlace)
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "mappin.circle")
                                .imageScale(.large)
                            
                            
                            Text("Location")
                            
                            Spacer()
                            
                            Text("\(ceVM.returnedPlace.name == "Unknown Location" ? "Select": ceVM.returnedPlace.name)")
                                .foregroundColor(.gray)
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                            
                        }
                        .createEventTabStyle()
                    }
                    
                    if noLocation {
                        WarningTextComponent(text: "Please select a location.")
                        
                    }
                    
                    NavigationLink {
                        AccessibilityView(selectedVisability: $ceVM.selectedVisability, askToJoin: $ceVM.askToJoin)
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "eye.circle")
                                .imageScale(.large)
                            
                            
                            Text("Accessibility")
                            
                            Spacer()
                            
                            if let visability = ceVM.selectedVisability {
                                Text(visability.value)
                                    .foregroundColor(.gray)
                            } else {
                                Text("Select")
                                    .foregroundColor(.gray)
                            }
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                            
                        }
                        .createEventTabStyle()
                    }
                    
                    if noVisability {
                        WarningTextComponent(text: "Please select a visability type.")
                        
                    }
                    
                    NavigationLink {
                        CategoryView(selectedInterests: $ceVM.selectedInterests, text: "Select at least one tag related to your event", minInterests: 0)
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "circle.grid.2x2")
                                .imageScale(.large)
                            
                            if $ceVM.selectedInterests.count > 0 {
                                Text(interestsOrder(ceVM.selectedInterests))
                                    .lineLimit(1)
                                Spacer()
                            } else {
                                Text("Interests")
                                Spacer()
                                Text("Select")
                                    .foregroundColor(.gray)
                            }
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                            
                        }
                        .createEventTabStyle()
                    }
                    
                    if noTag {
                        WarningTextComponent(text: "Please at least one interest.")
                        
                    }
                    
                    
                    Text("Aditional Options")
                        .font(.callout)
                        .foregroundStyle(.gray)
                        .fontWeight(.bold)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                        .padding(.horizontal, 8)
                    
                    NavigationLink {
                        DateView(isDate: $ceVM.isDate, date: $ceVM.date, from: $ceVM.from, to: $ceVM.to, daySettings: $ceVM.daySettings, timeSettings: $ceVM.timeSettings)
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "calendar")
                                .imageScale(.large)
                            
                            
                            Text("Date & Time")
                            
                            Spacer()
                            
                            
                            Text(ceVM.isDate ? separateDateAndTime(from:ceVM.date).date : "Any day")
                                .foregroundColor(.gray)
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                        }
                        .createEventTabStyle()
                    }
                    
                    VStack(alignment: .leading, spacing: 20){
                        
                        Button {
                            ceVM.showParticipants.toggle()
                        } label: {
                            
                            HStack(alignment: .center, spacing: 10) {
                                Image(systemName: "person.2.circle")
                                    .imageScale(.large)
                                
                                
                                Text("Participants")
                                
                                Spacer()
                                
                                if let participant = ceVM.participants{
                                    Text(participant > 0 ? "\(participant)" : "No Limit")
                                        .foregroundColor(.gray)
                                } else {
                                    Text("No Limit")
                                        .foregroundColor(.gray)
                                }
                                
                                Image(systemName: ceVM.showParticipants ? "chevron.down" : "chevron.right")
                                    .padding(.trailing, 10)
                                    .foregroundColor(.gray)
                                
                            }
                            
                        }
                        if ceVM.showParticipants {
                            HStack(alignment: .center, spacing: 10) {
                                Text("The number of participants")
                                
                                Spacer()
                                
                                TextField("Max", value: $ceVM.participants, format:.number)
                                    .foregroundColor(.gray)
                                    .frame(width: 70)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                
                            }
                            
                        }
                    }
                    .createEventTabStyle()
                    
                    VStack(alignment: .leading, spacing: 20){
                        Button {
                            ceVM.showPricing.toggle()
                        } label: {
                            
                            HStack(alignment: .center, spacing: 10) {
                                Image(systemName: "wallet.pass")
                                    .imageScale(.large)
                                
                                
                                Text("Price")
                                
                                Spacer()
                                
                                if let price = ceVM.price{
                                    
                                    Text(price > 0.0 ? "€ \(price, specifier: "%.2f")" : "Free")
                                        .foregroundColor(.gray)
                                } else {
                                    Text("Free")
                                        .foregroundColor(.gray)
                                }
                                
                                Image(systemName: ceVM.showPricing ? "chevron.down" : "chevron.right")
                                    .padding(.trailing, 10)
                                    .foregroundColor(.gray)
                                
                            }
                            
                        }
                        if ceVM.showPricing {
                            HStack(alignment: .center, spacing: 10) {
                                Text("Write a Price")
                                
                                Spacer()
                                
                                TextField("€ 0.00", value: $ceVM.price, format:.currency(code: "EUR"))
                                    .foregroundColor(.gray)
                                    .frame(width: 70)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                
                                
                            }
                        }
                    }
                    .createEventTabStyle()
                }
                .padding(.horizontal)
                
                
                if allRequirenments {
                    Button{
                        dismiss()
                    } label: {
                        Text("Create")
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                            .fontWeight(.semibold)
                    }
                    .padding()
                } else {
                    Text("Create")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(.gray)
                        .foregroundColor(Color("testColor"))
                        .cornerRadius(10)
                        .fontWeight(.semibold)
                        .padding()
                        .onTapGesture {
                            displayWarnings.toggle()
                        }
                }
                
            }
            .onTapGesture {
                hideKeyboard()
            }
            .frame(maxHeight: UIScreen.main.bounds.height,alignment: .top)
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:Button(action: {showExitSheet = true}) {
                Image(systemName: "xmark")
                    .imageScale(.medium)
                    .padding(.all, 8)
                    .background(Color("secondaryColor"))
                    .clipShape(Circle())
            }
            )
        }
        .sheet(isPresented: $showExitSheet, content: {
            onCloseTab()
        })
        .resignKeyboardOnDragGesture()
    }
    
    func onCloseTab() -> some View {
        VStack(spacing: 30){
            Text("On Exit all of the data will be lost.")
                .font(.headline)
                .fontWeight(.bold)
            
            Button{
                dismiss()
            } label:{
                Text("Exit")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(.red)
                    .cornerRadius(10)
            }
        }
        .padding()
        .presentationDetents([.fraction(0.2)])
    }
    
    var titleEmpty: Bool {
        if ceVM.title.isEmpty && displayWarnings {
            return true
        } else {
            return false
        }
    }
    
    var titleChartLimit: Bool {
        if !ceVM.title.isEmpty && displayWarnings && ceVM.title.count < 5 {
            return true
        } else {
            return false
        }
    }
    
    var noPhotos: Bool {
        if photoPickerVM.selectedImages.allSatisfy({ $0 == nil }) && displayWarnings{
            return true
        } else {
            return false
        }
    }
    
    var noLocation: Bool {
        if ceVM.returnedPlace.name == "Unknown Location" && displayWarnings {
            return true
        } else {
            return false
        }
    }
    
    var noVisability: Bool {
        if ceVM.selectedVisability == nil && displayWarnings {
            return true
        } else {
            return false
        }
    }
    
    var noTag: Bool {
        if ceVM.selectedInterests.count == 0 && displayWarnings {
            return true
        } else {
            return false
        }
    }
    
    var allRequirenments: Bool {
        if ceVM.title.count >= 5, !ceVM.title.isEmpty, ceVM.returnedPlace.name != "Unknown Location", photoPickerVM.selectedImages.contains(where: { $0 != nil }),ceVM.selectedInterests.count > 0 && ceVM.selectedVisability != nil {
            return true
        } else {
            return false
        }
    }
}

#Preview{
    CreateEventView()
        .environmentObject(UserViewModel())
        .environmentObject(LocationManager())
}

extension View {
    func createEventTabStyle() -> some View {
        self.font(.subheadline)
            .fontWeight(.semibold)
            .padding(.vertical, 5)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .normalTagRectangleStyle()
    }
}
