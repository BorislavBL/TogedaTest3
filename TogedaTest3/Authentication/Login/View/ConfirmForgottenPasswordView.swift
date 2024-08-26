//
//  ConfirmForgottenPasswordView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 23.08.24.
//

import SwiftUI

struct ConfirmForgottenPasswordView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @State private var displayError: Bool = false
    @Binding var isActive1: Bool
    @Binding var isActive2: Bool
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var email: String
    @State var password: String = ""
    @State var userId: String = ""
    @State var code: String = ""
    
    enum FocusedField: Hashable{
        case code, password1, password2
    }

    @FocusState private var focus: FocusedField?

    @State var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    
    
    var body: some View {
        VStack {
            Text("Enter the new Password!")
                .multilineTextAlignment(.center)
                .font(.title).bold()
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
            
            
            Text("Enter the code you received on your email.")
                .multilineTextAlignment(.leading)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            
            TextField("", text: $code)
                .placeholder(when: code.isEmpty) {
                    Text("Code")
                        .foregroundColor(.secondary)
                        .bold()
                }
                .bold()
                .focused($focus, equals: .code)
                .autocapitalization(.none)
                .keyboardType(.numberPad)
                .submitLabel(.done)
                .padding(10)
                .frame(minWidth: 80, minHeight: 47)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            
            if displayError && confirmPassword != password {
                WarningTextComponent(text: "The two passwords do not match.")
            } else if let message = errorMessage, !message.isEmpty {
                WarningTextComponent(text: message)
            } else if displayError && code.isEmpty {
                WarningTextComponent(text: "Please enter the code you received on your email.")
            }

            Spacer()
            
            Button{
                Task{
                    try await AuthService.shared.confirmForgotPassword(userEmail:email, newPassword: password, code: code){ success, error in
                        if let success = success, success {
                            DispatchQueue.main.async {
                                self.isActive2 = false
                                self.isActive1 = false
                            }
                        } else if let errorMessage = error {
                            DispatchQueue.main.async{
                                print("Error on the way")
                                self.errorMessage = errorMessage
                            }
                        }
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
            .disableWithOpacity(!samePassword || code.isEmpty)
            .onTapGesture {
                if !samePassword || code.isEmpty{
                    displayError.toggle()
                }
            }
            
        }
        .animation(.easeInOut(duration: 0.6), value: focus)
        .padding(.horizontal)
        .onAppear(){
            focus = .password1
        }
        .toolbar{
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardToolbarItems()
            }
        }
        .padding(.vertical)
        .swipeBack()
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
    ConfirmForgottenPasswordView(isActive1: .constant(true), isActive2: .constant(true), email: "")
}
