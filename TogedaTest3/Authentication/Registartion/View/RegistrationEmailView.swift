//
//  RegistartionEmailView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 14.12.23.
//

import SwiftUI

struct RegistrationEmailView: View {
    @ObservedObject var vm: RegistrationViewModel
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var keyIsFocused: Bool
    @Environment(\.dismiss) var dismiss

    @State private var displayError: Bool = false
    @State private var isActive: Bool = false
    @State private var isLoading = false
    @State private var alreadyTaken: Bool = false
    
    var body: some View {
        VStack {
            Text("What's your email?")
                .multilineTextAlignment(.center)
                .font(.title).bold()
                .padding(.top, 20)
            
            TextField("", text: $vm.createdUser.email)
                .placeholder(when: vm.createdUser.email.isEmpty) {
                    Text("Email")
                        .foregroundColor(.secondary)
                        .bold()
                }
                .bold()
                .focused($keyIsFocused)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .submitLabel(.next)
                .onSubmit {
                    if !isValidEmail(testStr: vm.createdUser.email) {
                        displayError.toggle()
                    } else{
                        isActive = true
                    }
                }
                .padding(10)
                .frame(minWidth: 80, minHeight: 47)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(.top, 20)
                .padding(.bottom, 15)
            
            
            if displayError {
                WarningTextComponent(text: "Please enter a valid email.")
                    .padding(.bottom, 15)
            } else if alreadyTaken {
                WarningTextComponent(text: "This email is already taken.")
                    .padding(.bottom, 15)
            }
            
            Button{
                vm.createdUser.subToEmail.toggle()
            } label: {
                HStack(alignment: .center, spacing: 16, content: {
                    Image(systemName: vm.createdUser.subToEmail ? "checkmark.square.fill" : "square")
                    Text("Would you like to receive news and updates from Togeda?")
                        .multilineTextAlignment(.leading)
                        .font(.footnote)
                        .bold()
                    
                })
                .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Button{
                Task{
                    defer { isLoading = false }
                    do {
                        alreadyTaken = try await AuthService().userExistsWithEmail(email: vm.createdUser.email)
                        if !alreadyTaken {
                            isActive = true
                        }
                    } catch GeneralError.encodingError{
                        print("Data encoding error")
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
            .disableWithOpacity(!isValidEmail(testStr: vm.createdUser.email))
            .onTapGesture {
                if !isValidEmail(testStr: vm.createdUser.email) {
                    displayError.toggle()
                }
            }
            
        }
        .animation(.easeInOut(duration: 0.6), value: keyIsFocused)
        .padding(.horizontal)
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear(){
            keyIsFocused = true
        }
        .ignoresSafeArea(.keyboard)
        .padding(.vertical)
        .navigationDestination(isPresented: $isActive, destination: {
            RegistrationPasswordView(vm: vm)
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
    RegistrationEmailView(vm: RegistrationViewModel())
}
