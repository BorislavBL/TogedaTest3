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
    @State var title: String = ""
    @State var showParticipants = false
    @State var participants: Int = 0
    @State var showPricing = false
    @State var price: Int = 0
    @State var showExitSheet: Bool = false
    @State var returnedPlace = Place(mapItem: MKMapItem())
    
    var body: some View {
        NavigationStack {
            VStack{
                ScrollView{
                    TextField("What event would you like to make?", text: $title, axis: .vertical)
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(2, reservesSpace: true)
                        .padding(.vertical)
                    
                    VStack(spacing: 10) {
                        Group{
                            
                            NavigationLink {
                                DateView()
                            } label: {
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "calendar")
                                        .imageScale(.large)
                                    
                                    
                                    Text("Date & Time")
                                    
                                    Spacer()
                                    
                                    Text("19/07/23")
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
                                DescriptionView()
                            } label: {
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "square.and.pencil")
                                        .imageScale(.large)
                                    
                                    
                                    Text("Description")
                                    
                                    Spacer()
                                    
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
                                    
                                    Text("Sofia, Bulgaria")
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
                                        
                                        Text("Any")
                                            .foregroundColor(.gray)
                                        
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
                                    
                                    Text("Free")
                                        .foregroundColor(.gray)
                                    
                                    Image(systemName: showPricing ? "chevron.down" : "chevron.right")
                                        .padding(.trailing, 10)
                                        .foregroundColor(.gray)
                                    
                                }
                            }
                                if showPricing {
                                    HStack(alignment: .center, spacing: 10) {
                                        Text("Write a Price")
                                        
                                        Spacer()
                                        
                                        TextField("Free", value: $price, format:.currency(code: "EUR"))
                                            .foregroundColor(.gray)
                                            .frame(width: 70)
                                            .textFieldStyle(.roundedBorder)
                                            
                                        
                                    }
                                }
                            }
                            
                            NavigationLink {
                                AccesabilityView()
                            } label: {
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "eye.circle")
                                        .imageScale(.large)
                                    
                                    
                                    Text("Accessability")
                                    
                                    Spacer()
                                    
                                    Text("Public")
                                        .foregroundColor(.gray)
                                    
                                    Image(systemName: "chevron.right")
                                        .padding(.trailing, 10)
                                        .foregroundColor(.gray)
                                    
                                    
                                }
                            }
                            
                            NavigationLink {
                                CategoryView(selectedCategory: "Sport", selectedInterests: [""])
                            } label: {
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "square.grid.2x2")
                                        .imageScale(.large)
                                    
                                    
                                    Text("Category")
                                    
                                    Spacer()
                                    
                                    Text("Sport")
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
                
                Button {
                    print("hello")
                } label: {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color("blackAndWhite"))
                        .foregroundColor(Color("testColor"))
                        .cornerRadius(10)
                        .fontWeight(.semibold)
                }
                .padding()

                
            }
            .frame(maxHeight: UIScreen.main.bounds.height,alignment: .top)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(trailing:Button(action: {showExitSheet = true}) {
                Image(systemName: "xmark")
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
