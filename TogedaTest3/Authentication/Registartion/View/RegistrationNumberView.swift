//
//  RegistrationNumberView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 16.01.24.
//

import SwiftUI

struct RegistrationNumberView: View {
    @ObservedObject var vm: RegistrationViewModel
    @EnvironmentObject var mainVm: ContentViewModel
    @State var presentSheet = false
    
    @State private var searchCountry: String = ""
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var keyIsFocused: Bool
    @Environment(\.dismiss) var dismiss
    @State private var displayError: Bool = false
    
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
            
            VStack(spacing: 16) {
                Text("Got a Friend's Referral Code? \n Enter it here!")
                    .bold()
                    .multilineTextAlignment(.center)
                
                TextField("", text: $vm.referralCode)
                    .placeholder(when: vm.referralCode.isEmpty) {
                        Text("Referral Code (Optional)")
                            .foregroundColor(.secondary)
                    }
                    .bold()
                    .keyboardType(.numberPad)
                    .padding(10)
                    .frame(minWidth: 80, minHeight: 47)
                    .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .padding()
            .background(.bar)
            .cornerRadius(10)
            .padding(.top, 20)
            
            Spacer()

            Button{
                withAnimation {
                    isLoading = true
                }

                Task{
                    errorMessage = nil
                    let body = vm.addUserInfoModel()
                    try await APIClient.shared.addUserInfo(body: body) { response, error in
                        DispatchQueue.main.async {
                            if let response = response, response {
                                withAnimation {
                                    self.isLoading = false
                                }
                                Task{
                                    await mainVm.validateTokensAndCheckState()
                                }
                            } else if let error = error {
                                withAnimation {
                                    self.isLoading = false
                                }
                                print("error")
                                self.errorMessage = error
                            }
                        }
                    }
                }
                    
            } label:{
                    Text("Submit")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color("blackAndWhite"))
                        .foregroundColor(Color("testColor"))
                        .cornerRadius(10)
                        .fontWeight(.semibold)
            }
            .disableWithOpacity(vm.mobPhoneNumber.count < 5)
            .onTapGesture {
                if vm.mobPhoneNumber.count < 5 {
                    displayError.toggle()
                }
            }
            
        }
        .animation(.easeInOut(duration: 0.6), value: keyIsFocused)
        .padding()
        .overlay {
            if isLoading {
                LoadingScreenView(isVisible: $isLoading)
            }
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
            if let emailSubscriptionData = KeychainManager.shared.retrieve(itemForAccount: userKeys.emailSubscription.toString, service: userKeys.service.toString) {
                if let bool = try? JSONDecoder().decode(Bool.self, from: emailSubscriptionData) {
                    vm.subToEmail = bool
                }
            }
        }
        .toolbar{
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardToolbarItems()
            }
        }
        .swipeBack()
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
    RegistrationNumberView(vm: RegistrationViewModel())
        .environmentObject(ContentViewModel())
}
