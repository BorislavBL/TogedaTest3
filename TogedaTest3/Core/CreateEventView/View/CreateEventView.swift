//
//  CreateEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @State var title: String = ""
    @State var showDate = false
    @State var showDescription = false
    @State var showParticipants = false
    @State var participants: Int = 0
    @State var showPricing = false
    @State var price: Int = 0
    @State var showAccessability = false
    @State var showCategory = false
    
    var body: some View {
        VStack{
            
            HStack{
                Spacer()
                Button(action:{dismiss()}) {
                    Image(systemName: "xmark")
                        .padding(.all, 8)
                        .background(Color("secondaryColor"))
                        .clipShape(Circle())
                }
            }
            .padding()
            
            ScrollView{
                TextField("What event would you like to make?", text: $title, axis: .vertical)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(2, reservesSpace: true)
                    .padding(.vertical)
                
                VStack(spacing: 10) {
                    Group{
                        Button {
                            showDate = true
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
                        
                        Button {
                            showDescription = true
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
                                    
                                    TextField("$", value: $price, format:.number)
                                        .foregroundColor(.gray)
                                        .frame(width: 70)
                                        .textFieldStyle(.roundedBorder)
                                        
                                    
                                }
                            }
                        }
                        
                        Button {
                            showAccessability = true
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
                        
                        Button {
                            showCategory = true
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
        .sheet(isPresented: $showDate) {
            DateView()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showDescription) {
            DescriptionView()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAccessability) {
            AccesabilityView()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showCategory) {
            CategoryView(selectedCategory: "Sport", selectedInterests: [""])
                .presentationDragIndicator(.visible)
        }
    }
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView()
    }
}
