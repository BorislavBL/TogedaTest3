//
//  EditProfilePhoneNumberView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 26.02.24.
//

import SwiftUI

struct EditProfilePhoneNumberView: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var nav: NavigationManager
    @State private var displayError: Bool = false
    @Environment(\.dismiss) var dismiss
    @State var isLoading = false
    @State private var errorMessage: String?
    
    @State var countryCode : String = "359"
    @State var countryFlag : String = "🇧🇬"
    @State var countryPattern : String = "#"
    @State var countryLimit : Int = 17
    @State var mobPhoneNumber = ""
    @State var showCodeView: Bool = false
    @State var code = ""
    
    var body: some View {
        PhoneNumberView(isLoading: $isLoading, countryCode: $countryCode, countryFlag: $countryFlag, countryPattern: $countryPattern, countryLimit: $countryLimit, mobPhoneNumber: $mobPhoneNumber) {
            
//            Task {
//                do{
//                    if try await UserService().editUserDetails(userData: nil, phoneNumber: countryCode+mobPhoneNumber) {
//                        try await userVM.fetchCurrentUser()
//                        nav.selectionPath.append(SelectionPath.editProfilePhoneCodeVerification)
//                        
//                    }
//                } catch GeneralError.badRequest(details: let details){
//                    print(details)
//                } catch GeneralError.invalidURL {
//                    print("Invalid URL")
//                } catch GeneralError.serverError(let statusCode, let details) {
//                    print("Status: \(statusCode) \n \(details)")
//                } catch {
//                    print("Error message:", error)
//                }
//                
//            }

        }
    }
}

#Preview {
    EditProfilePhoneNumberView()
        .environmentObject(UserViewModel())
        .environmentObject(NavigationManager())
}
