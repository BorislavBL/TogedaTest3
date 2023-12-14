//
//  RegistrationView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 13.12.23.
//

import SwiftUI

struct RegistrationView: View {
    @State var countryCode : String = "+359"
    @State var countryFlag : String = "🇧🇬"
    @State var countryPattern : String = "#"
    @State var countryLimit : Int = 17
    @State var mobPhoneNumber = ""
    var body: some View {
        CountryNumbersView(countryCode: $countryCode, countryFlag: $countryFlag, countryPattern: $countryPattern, countryLimit: $countryLimit, mobPhoneNumber: $mobPhoneNumber, currentDestination: AnyView(RegistrationCodeView()))
    }
}

#Preview {
    RegistrationView()
}
