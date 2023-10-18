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
    
    //Title
    @State var title: String = ""
    
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
    
    //Description View
    @State var description: String = ""
    
    //Accesability
    @State var selectedVisability: Visabilities = .Public
    
    //Category
    @State var selectedCategory: String = "Sport"
    @State var selectedInterests: [String] = [""]
    
    //PhotoPicker
    @StateObject var photoPickerVM = PhotoPickerViewModel()
    
    var body: some View {
        NavigationStack {
            VStack{
                ScrollView{
                    TextField("What event would you like to make?", text: $title, axis: .vertical)
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(2, reservesSpace: true)
                        .padding(.vertical)
                        .onChange(of: title) { oldValue, newValue in
                            if title.count > 70 {
                                title = String(title.prefix(70))
                            }
                        }
                    
                    VStack(spacing: 10) {
                        Group{
                            
                            NavigationLink {
                                PhotoPickerView(photoPickerVM: photoPickerVM)
                            } label: {
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "photo")
                                        .imageScale(.large)
                                    
                                    
                                    Text("Photos")
                                    
                                    Spacer()
                                    
                                    if photoPickerVM.selectedImages.contains(where: {$0 != nil}) {
                                        Text("Selected")
                                            .foregroundColor(.gray)
                                    } else {
                                        Text("Select")
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Image(systemName: "chevron.right")
                                        .padding(.trailing, 10)
                                        .foregroundColor(.gray)
                                    
                                    
                                }
                            }
                            
                            NavigationLink {
                                DateView(date: $date, from: $from, to: $to)
                            } label: {
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "calendar")
                                        .imageScale(.large)
                                    
                                    
                                    Text("Date & Time")
                                    
                                    Spacer()
                                    
                                    Text(separateDateAndTime(from:date).date)
                                        .foregroundColor(.gray)
                                    
                                    Image(systemName: "chevron.right")
                                        .padding(.trailing, 10)
                                        .foregroundColor(.gray)
                                    
                                }
                            }


    //                        HStack(alignment: .center, spacing: 10) {
    //                            Image(systemName: "clock")
    //                                .imageScale(.large)
    //
    //
    //                            Text("Time")
    //
    //                            Spacer()
    //
    //                            Text("13:00")
    //                                .foregroundColor(.gray)
    //
    //                            Image(systemName: "chevron.right")
    //                                .padding(.trailing, 10)
    //                                .foregroundColor(.gray)
    //
    //                        }
                            
                            
                            NavigationLink {
                                DescriptionView(description: $description)
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
                                            
                                        
                                    }
                                }
                            }

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
                            
                            NavigationLink {
                                AccesabilityView(selectedVisability: $selectedVisability)
                            } label: {
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "eye.circle")
                                        .imageScale(.large)
                                    
                                    
                                    Text("Accessability")
                                    
                                    Spacer()
                                    
                                    Text(selectedVisability.value)
                                        .foregroundColor(.gray)
                                    
                                    Image(systemName: "chevron.right")
                                        .padding(.trailing, 10)
                                        .foregroundColor(.gray)
                                    
                                    
                                }
                            }
                            
                            NavigationLink {
                                CategoryView(selectedCategory: $selectedCategory, selectedInterests: $selectedInterests)
                            } label: {
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "square.grid.2x2")
                                        .imageScale(.large)
                                    
                                    
                                    Text("Category")
                                    
                                    Spacer()
                                    
                                    Text(selectedCategory)
                                        .foregroundColor(.gray)
                                    
                                    Image(systemName: "chevron.right")
                                        .padding(.trailing, 10)
                                        .foregroundColor(.gray)
                                    
                                    
                                }
                            }
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.vertical, 5)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .normalTagRectangleStyle()
                    }

                }
                .padding(.horizontal)
                
                Spacer()
                
                if !title.isEmpty, returnedPlace.name != "Unknown Location" {
                    NavigationLink(destination: TestView()) {
                        Text("Next")
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                            .fontWeight(.semibold)
                    }
                    .padding()
                } else {
                        Text("Next")
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(.gray)
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                            .fontWeight(.semibold)
                            .padding()
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
    }
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView()
    }
}
