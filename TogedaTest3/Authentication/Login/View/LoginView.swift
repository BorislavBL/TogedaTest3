//
//  LoginView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 12.12.23.
//

import SwiftUI

struct LoginView: View {
    enum FocusedField: Hashable{
        case email, password
    }
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var focus: FocusedField?
    @Environment(\.dismiss) var dismiss
    @State var email: String = ""
    @State var password: String = ""
    @State private var displayError: Bool = false
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        VStack {
            Text("Sign In to Your Account")
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
                .autocapitalization(.none)
                .focused($focus, equals: .email)
                .onSubmit {
                    focus = .password
                }
                .keyboardType(.emailAddress)
                .padding(10)
                .frame(minWidth: 80, minHeight: 47)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(.top, 20)
            
            if displayError && !isValidEmail(testStr: email) {
                WarningTextComponent(text: "Please enter a valid email.")
                    .padding(.bottom, 15)
            }
            
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
                .focused($focus, equals: .password)
                .keyboardType(.default)
                .padding(10)
                .frame(minWidth: 80, minHeight: 47)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(.top, 2)
                .padding(.bottom, 15)
            
            if displayError && unvalidPassword {
                WarningTextComponent(text: "The password should be at least 6 characters long.")
                    .padding(.bottom, 15)
            }
            
            Button{
                
            } label: {
                HStack(alignment: .center, spacing: 16, content: {
                    Text("Forget Password?")
                        .multilineTextAlignment(.leading)
                        .bold()
                    
                })
                .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Button{
                
            } label: {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .cornerRadius(10)
                    .fontWeight(.semibold)
            }
            .disableWithOpacity(!isValidEmail(testStr: email) || unvalidPassword)
            .onTapGesture {
                if !isValidEmail(testStr: email) {
                    displayError.toggle()
                }
            }
            
        }
        .animation(.easeInOut(duration: 0.6), value: focus)
        .padding(.horizontal)
        .onTapGesture {
            hideKeyboard()
        }
        .ignoresSafeArea(.keyboard)
        .padding(.vertical)
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
    
    var unvalidPassword: Bool {
        if password.count < 6 {
            return true
        } else {
            return false
        }
    }

}

#Preview {
    LoginView()
}
