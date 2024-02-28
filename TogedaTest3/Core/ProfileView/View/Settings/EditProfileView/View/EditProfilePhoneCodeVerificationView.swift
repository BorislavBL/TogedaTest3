//
//  EditProfilePhoneCodeVerificationView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 28.02.24.
//

import SwiftUI

struct EditProfilePhoneCodeVerificationView: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var nav: NavigationManager
    @State var code: String = ""
    var body: some View {
        PhoneNumberCodeView(code: $code) {
            code = ""
            verifyUserPhoneNumber()
            
        } submitFunc: {
            Task{
                do {
                    if try await AuthService.shared.confirmVerifyUserPhoneNumber(code: code) {
                        try await userVM.fetchCurrentUser()
                        nav.selectionPath.removeLast(2)
                    }
                } catch GeneralError.badRequest(details: let details){
                    print(details)
                } catch GeneralError.invalidURL {
                    print("Invalid URL")
                } catch GeneralError.serverError(let statusCode, let details) {
                    print("Status: \(statusCode) \n \(details)")
                } catch {
                    print("Error message:", error)
                }
            }
        }
        .onAppear(){
            verifyUserPhoneNumber()
        }
    }
    
    func verifyUserPhoneNumber() {
        Task{
            do {
                let _ = try await AuthService.shared.verifyUserPhoneNumber()
            } catch GeneralError.badRequest(details: let details){
                print(details)
            } catch GeneralError.invalidURL {
                print("Invalid URL")
            } catch GeneralError.serverError(let statusCode, let details) {
                print("Status: \(statusCode) \n \(details)")
            } catch {
                print("Error message:", error)
            }
        }
    }
}

#Preview {
    EditProfilePhoneCodeVerificationView()
        .environmentObject(UserViewModel())
        .environmentObject(NavigationManager())
}
