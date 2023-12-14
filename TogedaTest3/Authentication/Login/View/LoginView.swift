//
//  LoginView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 12.12.23.
//

import SwiftUI
import Combine

struct LoginView: View {
    @State var countryCode : String = "+359"
    @State var countryFlag : String = "🇧🇬"
    @State var countryPattern : String = "#"
    @State var countryLimit : Int = 17
    @State var mobPhoneNumber = ""
    
    var body: some View {
        CountryNumbersView(countryCode: $countryCode, countryFlag: $countryFlag, countryPattern: $countryPattern, countryLimit: $countryLimit, mobPhoneNumber: $mobPhoneNumber, currentDestination: AnyView(LoginCodeView()))
    }
}

#Preview {
    LoginView(countryCode: "+359", countryFlag: "🇧🇬", countryPattern: "#", countryLimit: 17)
}
