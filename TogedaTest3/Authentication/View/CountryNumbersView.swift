//
//  CountryNumbersView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 14.12.23.
//

import SwiftUI
import Combine

struct CountryNumbersView: View {
    @State var presentSheet = false
    @Binding var countryCode : String
    @Binding var countryFlag : String
    @Binding var countryPattern : String
    @Binding var countryLimit : Int
    @Binding var mobPhoneNumber: String
    @State private var searchCountry: String = ""
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var keyIsFocused: Bool
    @Environment(\.dismiss) var dismiss
    @State private var displayError: Bool = false
    
    var currentDestination: AnyView
    let counrties: [CPData] = Bundle.main.decode("CountryNumbers.json")
    
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
                    Text("\(countryFlag) \(countryCode)")
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
                    .onReceive(Just(mobPhoneNumber)) { _ in
                        applyPatternOnNumbers(&mobPhoneNumber, pattern: countryPattern, replacementCharacter: "#")
                    }
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
            
            Spacer()
            
            NavigationLink(destination: currentDestination){
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .cornerRadius(10)
                    .fontWeight(.semibold)
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
                        Text(country.dial_code)
                            .foregroundColor(.secondary)
                    }
                    .onTapGesture {
                        self.countryFlag = country.flag
                        self.countryCode = country.dial_code
                        self.countryPattern = country.pattern
                        self.countryLimit = country.limit
                        presentSheet = false
                        searchCountry = ""
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchCountry, placement:.navigationBarDrawer(displayMode: .always) )
            }
            .presentationDetents([.large])
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
            return counrties
        } else {
            return counrties.filter { $0.name.contains(searchCountry) }
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
    
    func applyPatternOnNumbers(_ stringvar: inout String, pattern: String, replacementCharacter: Character) {
        var pureNumber = stringvar.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else {
                stringvar = pureNumber
                return
            }
            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        stringvar = pureNumber
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}
extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}
extension View {
    func disableWithOpacity(_ condition: Bool) -> some View {
        self
            .disabled(condition)
            .opacity(condition ? 0.6 : 1)
    }
}
struct OnboardingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous )
                .frame(height: 49)
                .foregroundColor(Color(.systemBlue))
            
            configuration.label
                .fontWeight(.semibold)
                .foregroundColor(Color(.white))
        }
    }
}

#Preview {
    CountryNumbersView(countryCode: .constant("+359"), countryFlag: .constant("🇧🇬"), countryPattern: .constant("#"), countryLimit: .constant(17), mobPhoneNumber: .constant(""), currentDestination: AnyView(LoginCodeView()))
}
