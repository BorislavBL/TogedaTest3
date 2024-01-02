//
//  TestCreateEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 2.12.23.
//

import SwiftUI
import MapKit

struct TestCreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @State var showExitSheet: Bool = false
    @State var displayWarnings: Bool = false
    @State var alertMessage = ""
    //Title
    @State var title: String = ""
    @State var placeholder: String = "What event would you like to make?"
    @FocusState private var focusedField: Bool
    
    @State private var name = "Taylor Swift"
    
    //Participants View
    @State var showParticipants = false
    @State var participants: Int?
    
    //Pricing View
    @State var showPricing = false
    @State var price: Double?
    
    //Location View
    @State var returnedPlace = Place(mapItem: MKMapItem())
    
    //Date View
    @State var date = Date()
    @State var from = Date()
    @State var to = Date()
    @State var isDate = true
    @State var daySettings = 0
    @State var timeSettings = 0
    
    //Description View
    @State var description: String = ""
    
    //Accesability
    @State var selectedVisability: Visabilities = .Public
    
    //Category
    @State var selectedCategory: String?
    @State var selectedInterests: [String] = []
    
    //PhotoPicker
    @StateObject var photoPickerVM = PhotoPickerViewModel()
    
    let descriptionPlaceholder = "Describe the purpose of your event. What activities are you planning? Mention any special guests who might be attending. Will there be food and drinks? Help attendees know what to expect."
    
    var body: some View {
        NavigationStack {
            VStack{
                
                ScrollView(showsIndicators: false){
                    //                    TextField(placeholder, text: $title, axis: .vertical)
                    //                        .submitLabel(.done)
                    //                        .focused($isTitle)
                    //                        .onSubmit {
                    //                            isTitle = false
                    //                            print("ok")
                    //                        }
                    //                        .font(.headline)
                    //                        .fontWeight(.bold)
                    //                        .lineLimit(2, reservesSpace: true)
                    //                        .padding(.vertical)
                    //                        .onChange(of: title) { oldValue, newValue in
                    //                            if title.count > 70 {
                    //                                title = String(title.prefix(70))
                    //                            }
                    //                        }
                    

                    
                    VStack(alignment: .leading){
                        Text("Title:")
                            .foregroundStyle(.tint)
                        TextField(placeholder, text: $title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .onChange(of: title) { oldValue, newValue in
                                if title.count > 70 {
                                    title = String(title.prefix(70))
                                }
                            }
                    }
                    .createEventTabStyle()
                    .padding(.top)
                    
                    if title.isEmpty && displayWarnings {
                        warningComponent(text: "Please write a title.")
                            .padding(.bottom, 8)
                    }
                    
                    
                    
                    VStack(spacing: 10) {
                        
                        NavigationLink {
                            DescriptionView(description: $description, placeholder: descriptionPlaceholder)
                        } label: {
                            HStack(alignment: .center, spacing: 10) {
                                Image(systemName: "square.and.pencil")
                                    .imageScale(.large)
                                
                                
                                Text("Description")
                                
                                Spacer()
                                
                                Text(description)
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
                        
                        if photoPickerVM.selectedImages.allSatisfy({ $0 == nil }) && displayWarnings {
                            warningComponent(text: "Please add photos.")
                                .padding(.bottom, 8)
                        }
                            
                            
                            NavigationLink {
                                LocationPicker(returnedPlace: $returnedPlace)
                            } label: {
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "mappin.circle")
                                        .imageScale(.large)
                                    
                                    
                                    Text("Location")
                                    
                                    Spacer()
                                    
                                    Text("\(returnedPlace.name == "Unknown Location" ? "Select": returnedPlace.name)")
                                        .foregroundColor(.gray)
                                    
                                    Image(systemName: "chevron.right")
                                        .padding(.trailing, 10)
                                        .foregroundColor(.gray)
                                  
                                    
                                }
                                .createEventTabStyle()
                            }
                        
                        if returnedPlace.name == "Unknown Location" && displayWarnings {
                            warningComponent(text: "Please select a location.")
                                .padding(.bottom, 8)
                        }
                        
                            
                            Text("Aditional Options")
                            .font(.callout)
                            .foregroundStyle(.gray)
                            .fontWeight(.bold)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                            .padding(.horizontal, 8)
                        
                            NavigationLink {
                                DateView(isDate: $isDate, date: $date, from: $from, to: $to, daySettings: $daySettings, timeSettings: $timeSettings)
                            } label: {
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "calendar")
                                        .imageScale(.large)
                                    
                                    
                                    Text("Date & Time")
                                    
                                    Spacer()
                                    
                                    
                                    Text(isDate ? separateDateAndTime(from:date).date : "Any day")
                                        .foregroundColor(.gray)
                                    
                                    Image(systemName: "chevron.right")
                                        .padding(.trailing, 10)
                                        .foregroundColor(.gray)
                                    
                                }
                                .createEventTabStyle()
                            }
                            
                            VStack(alignment: .leading, spacing: 20){
                                
                                Button {
                                    showParticipants.toggle()
                                } label: {
                                    
                                    HStack(alignment: .center, spacing: 10) {
                                        Image(systemName: "person.2.circle")
                                            .imageScale(.large)
                                        
                                        
                                        Text("Participants")
                                        
                                        Spacer()
                                        
                                        if let participant = participants{
                                            Text(participant > 0 ? "\(participant)" : "No Limit")
                                                .foregroundColor(.gray)
                                        } else {
                                            Text("No Limit")
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Image(systemName: showParticipants ? "chevron.down" : "chevron.right")
                                            .padding(.trailing, 10)
                                            .foregroundColor(.gray)
                                        
                                    }
                                    
                                }
                                if showParticipants {
                                    HStack(alignment: .center, spacing: 10) {
                                        Text("The number of participants")
                                        
                                        Spacer()
                                        
                                        TextField("Max", value: $participants, format:.number)
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
                                    showPricing.toggle()
                                } label: {
                                    
                                    HStack(alignment: .center, spacing: 10) {
                                        Image(systemName: "wallet.pass")
                                            .imageScale(.large)
                                        
                                        
                                        Text("Price")
                                        
                                        Spacer()
                                        
                                        if let price = self.price{
                                            
                                            Text(price > 0.0 ? "€ \(price, specifier: "%.2f")" : "Free")
                                                .foregroundColor(.gray)
                                        } else {
                                            Text("Free")
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Image(systemName: showPricing ? "chevron.down" : "chevron.right")
                                            .padding(.trailing, 10)
                                            .foregroundColor(.gray)
                                        
                                    }
                                    
                                }
                                if showPricing {
                                    HStack(alignment: .center, spacing: 10) {
                                        Text("Write a Price")
                                        
                                        Spacer()
                                        
                                        TextField("€ 0.00", value: $price, format:.currency(code: "EUR"))
                                            .foregroundColor(.gray)
                                            .frame(width: 70)
                                            .textFieldStyle(.roundedBorder)
                                            .keyboardType(.numberPad)
                                        
                                        
                                    }
                                }
                            }
                            .createEventTabStyle()
                            
                            NavigationLink {
                                AccessibilityView(selectedVisability: $selectedVisability)
                            } label: {
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "eye.circle")
                                        .imageScale(.large)
                                    
                                    
                                    Text("Accessibility")
                                    
                                    Spacer()
                                    
                                    Text(selectedVisability.value)
                                        .foregroundColor(.gray)
                                    
                                    Image(systemName: "chevron.right")
                                        .padding(.trailing, 10)
                                        .foregroundColor(.gray)
                                    
                                    
                                }
                                .createEventTabStyle()
                            }
                            
                            NavigationLink {
                                CategoryView(selectedCategory: $selectedCategory, selectedInterests: $selectedInterests)
                            } label: {
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "square.grid.2x2")
                                        .imageScale(.large)
                                    
                                    
                                    Text("Category")
                                    
                                    Spacer()
                                    
                                    if let category = selectedCategory {
                                        Text(category)
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
                        
                        
                        
                    }
                    
                }
                .padding(.horizontal)
                
                //                Spacer()
                
                if !title.isEmpty, returnedPlace.name != "Unknown Location", photoPickerVM.selectedImages.contains(where: { $0 != nil }) {
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
                            warningCondition()
                            displayWarnings = true
                        }
                }
                
            }
            .frame(maxHeight: UIScreen.main.bounds.height,alignment: .top)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(trailing:Button(action: {showExitSheet = true}) {
                Image(systemName: "xmark")
                    .imageScale(.medium)
                    .padding(.all, 8)
                    .background(Color("secondaryColor"))
                    .clipShape(Circle())
            }
            )
        }
//        .alert(alertMessage, isPresented: $displayWarnings) {
//            Button("OK", role: .cancel) { }
//        }
        .sheet(isPresented: $showExitSheet, content: {
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
        })
        .resignKeyboardOnDragGesture()
    }
    
    @ViewBuilder
    func warningComponent(text: String)-> some View {
        HStack{
            Image(systemName: "exclamationmark.circle")
            Text(text)
        }
        .foregroundStyle(.red)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
    
    func warningCondition() {
        let text = "In order to create an event you first have to:"
        let title = title.isEmpty ? "\n Write a suitable title." : ""
        let photos = photoPickerVM.selectedImages.contains(where: { $0 == nil }) ? "\n Select suitable photos." : ""
        let location = returnedPlace.name == "Unknown Location" ? "\n Select a disired location." : ""
        
        alertMessage = text + title + photos + location
    }
}

#Preview {
    TestCreateEventView()
        .environmentObject(UserViewModel())
        .environmentObject(LocationManager())
}
