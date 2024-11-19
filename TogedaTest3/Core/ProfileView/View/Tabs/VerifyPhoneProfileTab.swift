//
//  VerifyPhoneProfileTab.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 28.02.24.
//

import SwiftUI

struct VerifyPhoneProfileTab: View {
    var body: some View {
        VStack (alignment: .leading) {
            Text("Verify Phone Number")
                .font(.body)
                .fontWeight(.bold)
                .padding(.bottom, 30)
            
            HStack(alignment: .center){
                Image(systemName: "exclamationmark.circle")
                Text("Verify your phone number to unlock all of the app capabilities.")
                    .font(.footnote)
                    .fontWeight(.bold)
            }
            .foregroundStyle(.red)
            .padding(.bottom, 10)
            
            NavigationLink(value: SelectionPath.editProfilePhoneNumberMain) {
                Text("Verify")
                    .font(.subheadline)
                    .foregroundStyle(Color("base"))
                    .fontWeight(.semibold)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 13)
                    .background{Color("blackAndWhite")}
                    .cornerRadius(10)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.bar)
        .cornerRadius(10)
    }
}

#Preview {
    VerifyPhoneProfileTab()
}
