//
//  RegistrationCodeView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 14.12.23.
//

import SwiftUI

struct RegistrationCodeView: View {
    @ObservedObject var vm: RegistrationViewModel
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var keyIsFocused: Bool
    @Environment(\.dismiss) var dismiss
    
    @State private var displayError: Bool = false
    @State private var isActive: Bool = false
    
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            Text("Please enter the verification code you have received on your email.")
                .multilineTextAlignment(.center)
                .font(.title).bold()
                .padding(.top, 20)
            
            TextField("", text: $vm.code)
                .placeholder(when: vm.code.isEmpty) {
                    Text("Code")
                        .foregroundColor(.secondary)
                        .bold()
                }
                .onChange(of: vm.code) { oldValue, newValue in
                    if vm.code.count > 6 {
                        vm.code = String(vm.code.prefix(6))
                    }
                }
                .bold()
                .focused($keyIsFocused)
                .keyboardType(.numberPad)
                .padding(10)
                .frame(minWidth: 80, minHeight: 47)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(.top, 20)
                .padding(.bottom, 15)
            
            if displayError {
                WarningTextComponent(text: "Please enter the code. If you haven't received it chlick on the resend button.")
                    .padding(.bottom, 15)
            }
            
            if let message = errorMessage {
                WarningTextComponent(text: message)
                    .padding(.bottom, 15)
            }
            
            Button{
                vm.code = ""
                Task{
                    do {
                        try await AuthService.shared.resendSignUpCode(email: vm.createdUser.email)
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
            } label: {
                HStack(alignment: .top, content: {
                    Image(systemName: "gobackward")
                    Text("Resend the code")
                        .bold()
                    
                })
                .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Button{
                Task{
                    do {
                        if let userId = vm.userId, let code = Int(vm.code){
                            try await AuthService.shared.confirmSignUp(userId: userId, code: code)
                            isActive = true
                        }
                    } catch GeneralError.badRequest(details: let details){
                        print(details)
                        errorMessage = "Invalid Code"
                    } catch GeneralError.invalidURL {
                        print("Invalid URL")
                    } catch GeneralError.serverError(let statusCode, let details) {
                        print("Status: \(statusCode) \n \(details)")
                    } catch {
                        print("Error message:", error)
                    }
                }
            } label:{
                Text("Complete")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .cornerRadius(10)
                    .fontWeight(.semibold)
            }
            .disableWithOpacity(vm.code.count < 6)
            .onTapGesture {
                if vm.code.count < 4 {
                    displayError.toggle()
                }
            }
            
        }
        .animation(.easeInOut(duration: 0.6), value: keyIsFocused)
        .padding(.horizontal)
        
        .onTapGesture {
            hideKeyboard()
        }
        .ignoresSafeArea(.keyboard)
        .padding(.vertical)
        .navigationDestination(isPresented: $isActive, destination: {
            LoginView()
        })
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .frame(width: 35, height: 35)
                .background(Color(.tertiarySystemFill))
                .clipShape(Circle())
        })
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
    RegistrationCodeView(vm: RegistrationViewModel())
}
