//
//  RegistartionEmailView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 14.12.23.
//

import SwiftUI
import AWSCognitoIdentityProvider

struct RegistrationView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @State private var displayError: Bool = false
    @State private var isActive: Bool = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State var email: String = ""
    @State var password: String = ""
    
    enum FocusedField: Hashable{
        case email, password1, password2
    }

    @FocusState private var focus: FocusedField?

    @State var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    
    
    var body: some View {
        VStack {
            Text("Create an account")
                .multilineTextAlignment(.center)
                .font(.title).bold()
                .padding(.top, 20)
            
            TextField("", text: $email)
                .placeholder(when: email.isEmpty) {
                    Text("Email")
                        .foregroundColor(.secondary)
                        .bold()
                }
                .bold()
                .focused($focus, equals: .email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .submitLabel(.next)
                .onSubmit {
                    if !isValidEmail(testStr: email) {
                        displayError.toggle()
                    } else{
                        focus = .password1
                    }
                }
                .padding(10)
                .frame(minWidth: 80, minHeight: 47)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(.top, 20)
            
            
            HStack{
                if isPasswordVisible{
                    TextField("", text: $password)
                } else {
                    SecureField("", text: $password)
                }
                
                Button{
                    isPasswordVisible.toggle()
                } label:{
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundStyle(.gray)
                }
            }
            .placeholder(when: password.isEmpty) {
                Text("Password")
                    .foregroundColor(.secondary)
                    .bold()
            }
            
            .bold()
            .autocapitalization(.none)
            .focused($focus, equals: .password1)
            .submitLabel(.next)
            .onSubmit {
                focus = .password2
            }
            .padding(10)
            .frame(minWidth: 80, minHeight: 47)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            
            HStack{
                if isPasswordVisible{
                    TextField("", text: $confirmPassword)
                } else {
                    SecureField("", text: $confirmPassword)
                }
                
                Button{
                    isPasswordVisible.toggle()
                } label:{
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundStyle(.gray)
                }
            }
            .placeholder(when: confirmPassword.isEmpty) {
                Text("Confirm Password")
                    .foregroundColor(.secondary)
                    .bold()
            }
            .bold()
            .focused($focus, equals: .password2)
            .submitLabel(.done)
            .onSubmit {
                hideKeyboard()
            }
            .padding(10)
            .frame(minWidth: 80, minHeight: 47)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.top, 2)
            .padding(.bottom, 15)
            
            if !isValidEmail(testStr: email) && displayError {
                WarningTextComponent(text: "Please enter a valid email.")
                    .padding(.bottom, 15)
            } else if displayError && confirmPassword != password {
                WarningTextComponent(text: "The two passwords do not match.")
            } else if let message = errorMessage, !message.isEmpty {
                WarningTextComponent(text: message)
            }
            
//            Button{
//                vm.createdUser.subToEmail.toggle()
//            } label: {
//                HStack(alignment: .center, spacing: 16, content: {
//                    Image(systemName: vm.createdUser.subToEmail ? "checkmark.square.fill" : "square")
//                    Text("Would you like to receive news and updates from Togeda?")
//                        .multilineTextAlignment(.leading)
//                        .font(.footnote)
//                        .bold()
//                    
//                })
//                .foregroundStyle(.gray)
//            }
            
            Spacer()
            
            Button{
                AuthClient.shared.singUp(email: email, password: password) { success, error in
                    if success {
                        isLoading = false
                        isActive = true
                    } else if let errorMessage = error {
                        isLoading = false
                        self.errorMessage = errorMessage
                    } else {
                        isLoading = false
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
                    Text("Submit")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color("blackAndWhite"))
                        .foregroundColor(Color("testColor"))
                        .cornerRadius(10)
                        .fontWeight(.semibold)
                }
            }
            .disableWithOpacity(!isValidEmail(testStr: email) || !samePassword)
            .onTapGesture {
                if !isValidEmail(testStr: email) || !samePassword{
                    displayError.toggle()
                }
            }
            
        }
        .animation(.easeInOut(duration: 0.6), value: focus)
        .padding(.horizontal)
        .onAppear(){
            focus = .email
        }
        .toolbar{
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardToolbarItems()
            }
        }
        .padding(.vertical)
        .navigationDestination(isPresented: $isActive, destination: {
            RegistrationCodeView(email: $email, password: $password)
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
    
    var samePassword: Bool {
        if confirmPassword == password && !password.isEmpty{
            return true
        } else {
            return false
        }
    }
}

#Preview {
    RegistrationView()
}
