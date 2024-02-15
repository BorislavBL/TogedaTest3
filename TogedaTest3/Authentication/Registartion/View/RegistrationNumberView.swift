//
//  RegistrationNumberView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 16.01.24.
//

import SwiftUI

struct RegistrationNumberView: View {
    @ObservedObject var vm: RegistrationViewModel
    @State var presentSheet = false
    
    @State private var searchCountry: String = ""
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var keyIsFocused: Bool
    @Environment(\.dismiss) var dismiss
    @State private var displayError: Bool = false
    
    @State private var isActive = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    @State var countries: [CPData] = []
    
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
                    Text("\(vm.countryFlag) +\(vm.countryCode)")
                        .padding(10)
                        .frame(minWidth: 80, minHeight: 47)
                        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .foregroundColor(foregroundColor)
                        .bold()
                }
                
                TextField("", text: $vm.mobPhoneNumber)
                    .placeholder(when: vm.mobPhoneNumber.isEmpty) {
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
                isLoading = true
                print(vm.createdUser)
                
                Task{
                    defer { isLoading = false }
                    do {
                        vm.userId = try await AuthService.shared.createUser(userData: vm.createdUser)
                        isActive = true
                    } catch GeneralError.encodingError{
                        print("Data encoding error")
                    } catch GeneralError.badRequest(details: let details){
                        print(details)
                        errorMessage = "Invalid phone number."
                    } catch GeneralError.invalidURL {
                        print("Invalid URL")
                    } catch GeneralError.serverError(let statusCode, let details) {
                        print("Status: \(statusCode) \n \(details)")
                    } catch {
                        print("Error message:", error)
                    }
                }
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
            .disableWithOpacity(vm.mobPhoneNumber.count < 5)
            .onTapGesture {
                if vm.mobPhoneNumber.count < 5 {
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
                        vm.countryFlag = country.flag
                        vm.countryCode = country.dial_code
                        vm.countryPattern = country.pattern
                        vm.countryLimit = country.limit
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
        .navigationDestination(isPresented: $isActive, destination: {
            RegistrationCodeView(vm: vm)
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
    
    func validate(value: String) -> Bool {
            let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
            let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
            let result = phoneTest.evaluate(with: value)
            return result
    }
}

#Preview {
    RegistrationNumberView(vm: RegistrationViewModel())
}
