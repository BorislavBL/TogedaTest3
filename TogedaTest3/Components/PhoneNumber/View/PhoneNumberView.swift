//
//  PhoneNumberView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 27.02.24.
//

import SwiftUI

struct PhoneNumberView: View {
    @StateObject var vm = NumberViewModel()
    
    @State var presentSheet = false
    
    @State private var searchCountry: String = ""
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var keyIsFocused: Bool
    @State private var displayError: Bool = false
    @Environment(\.dismiss) var dismiss

    @Binding var isLoading: Bool
    @State private var errorMessage: String?
    
    @Binding var countryCode: String
    @Binding var countryFlag: String
    @Binding var countryPattern: String
    @Binding var countryLimit: Int
    @Binding var mobPhoneNumber: String

    @State var countries: [CPData] = []
    
    var submitFunc: ()-> Void
    
    var body: some View {
        VStack {
            
            Text("Confirm country code and enter phone number")
                .multilineTextAlignment(.center)
                .font(.title).bold()
                .padding(.top, 20)
            
            HStack {
                Button {
                    presentSheet = true
                    keyIsFocused = false
                } label: {
                    Text("\(countryFlag) +\(countryCode)")
                        .padding(10)
                        .frame(minWidth: 80, minHeight: 47)
                        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .foregroundColor(foregroundColor)
                        .bold()
                }
                
                TextField("", text: $mobPhoneNumber)
                    .placeholder(when: mobPhoneNumber.isEmpty) {
                        Text("Phone number")
                            .foregroundColor(.secondary)
                    }
                    .bold()
                    .focused($keyIsFocused)
                    .keyboardType(.numberPad)
                    .padding(10)
                    .frame(minWidth: 80, minHeight: 47)
                    .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            
            }
            .padding(.top, 20)
            .padding(.bottom, 15)
            
            if displayError {
                WarningTextComponent(text: "Please enter a valid number.")
                    .padding(.bottom, 15)
            }
            
            if let message = errorMessage {
                WarningTextComponent(text: message)
                    .padding(.bottom, 15)
            }
            
            Spacer()

            Button{
                submitFunc()
                
            } label:{
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color("blackAndWhite"))
                        .foregroundColor(Color("testColor"))
                        .cornerRadius(10)
                        .fontWeight(.semibold)
                } else {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color("blackAndWhite"))
                        .foregroundColor(Color("testColor"))
                        .cornerRadius(10)
                        .fontWeight(.semibold)
                }
            }
            .disableWithOpacity(mobPhoneNumber.count < 5)
            .onTapGesture {
                if mobPhoneNumber.count < 5 {
                    displayError.toggle()
                }
            }
            
        }
        .animation(.easeInOut(duration: 0.6), value: keyIsFocused)
        .padding(.horizontal)
        
        .onTapGesture {
            hideKeyboard()
        }
        .sheet(isPresented: $presentSheet) {
            NavigationView {
                List(filteredResorts) { country in
                    HStack {
                        Text(country.flag)
                        Text(country.name)
                            .font(.headline)
                        Spacer()
                        Text("+\(country.dial_code)")
                            .foregroundColor(.secondary)
                    }
                    .onTapGesture {
                        countryFlag = country.flag
                        countryCode = country.dial_code
                        countryPattern = country.pattern
                        countryLimit = country.limit
                        presentSheet = false
                        searchCountry = ""
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchCountry, placement:.navigationBarDrawer(displayMode: .always) )
            }
            .presentationDetents([.large])
        }
        .onAppear(){
            keyIsFocused = true
            countries = vm.loadJsonData()
        }
        .ignoresSafeArea(.keyboard)
        .padding(.vertical)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .frame(width: 35, height: 35)
                .background(Color(.tertiarySystemFill))
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
        })
        


    }
    
    var filteredResorts: [CPData] {
        if searchCountry.isEmpty {
            return countries
        } else {
            return countries.filter { $0.name.contains(searchCountry) }
        }
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
    PhoneNumberView(isLoading: .constant(false), countryCode: .constant(""), countryFlag: .constant(""), countryPattern: .constant(""), countryLimit: .constant(17), mobPhoneNumber: .constant(""), submitFunc: {})
}
