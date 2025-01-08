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
    @State private var errorMessage: String?
    
    @State private var saveLogin: Bool = true
    @State private var isNotEmailConfirmed = false
    
    @State var forgotPassword = false
    @EnvironmentObject var mainVm: ContentViewModel
    
    @State var userId: String = ""
    
    var body: some View {
        VStack {
            ScrollView {
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
                        .padding(.top)
                    
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
                    
                    if let message = errorMessage {
                        WarningTextComponent(text: message)
                            .padding(.bottom, 15)
                    }
                    
                    //            Button{
                    //                saveLogin.toggle()
                    //            } label: {
                    //                HStack(alignment: .center, spacing: 16, content: {
                    //                    Image(systemName: saveLogin ? "checkmark.square.fill" : "square")
                    //                    Text("Stay logged in")
                    //                        .multilineTextAlignment(.leading)
                    //                        .bold()
                    //                    
                    //                })
                    //                .foregroundStyle(.gray)
                    //                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    //            }
                    //            .padding(.bottom, 10)
                    
                    Button{
                        forgotPassword = true
                    } label: {
                        HStack(alignment: .center, spacing: 16, content: {
                            Text("Forget Password?")
                                .multilineTextAlignment(.leading)
                                .font(.footnote)
                                .bold()
                            
                        })
                        .foregroundStyle(.blue)
                    }
                    
                    
                }
                .padding()
                
               
            }
            .scrollIndicators(.hidden)
            
            Spacer()
            
            Button{
                errorMessage = nil
                
                Task{
                    try await AuthService.shared.login(email: email, password: password) { response, error  in
                        if let response = response {
                            print("Success")
                            let _ = KeychainManager.shared.saveOrUpdate(item: response.refreshToken, account: userKeys.refreshToken.toString, service: userKeys.service.toString)
                            
                            let _ = KeychainManager.shared.saveOrUpdate(item: response.accessToken, account: userKeys.accessToken.toString, service: userKeys.service.toString)
                            
                            let _ = KeychainManager.shared.saveOrUpdate(item: response.userId, account: userKeys.userId.toString, service: userKeys.service.toString)
                            
                            self.userId = response.userId
                            
                            Task{
                                await mainVm.validateTokensAndCheckState()
                            }
                            self.errorMessage = nil
                        } else if let message = error {
                            if message.lowercased().contains("user is not confirmed".lowercased()) {
                                self.errorMessage = "Email is not confirmed."
                                isNotEmailConfirmed = true
                                
                            } else if message.lowercased().contains("incorrect username or password".lowercased()) {
                                self.errorMessage = "Incorrect email or password"
                            } else if message.lowercased().hasPrefix("user is disabled") {
                                self.errorMessage = "This user is blocked: contact us at info@togeda.net"
                            } else {
                                self.errorMessage = message
                            }
                        }
                    }
                }
                
            } label: {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .cornerRadius(10)
                    .fontWeight(.semibold)
            }
            .padding([.bottom, .horizontal])
            .disableWithOpacity(!isValidEmail(testStr: email) || unvalidPassword || email.isEmpty || password.isEmpty)
            .onTapGesture {
                if !isValidEmail(testStr: email) || email.isEmpty || unvalidPassword || password.isEmpty {
                    displayError.toggle()
                }
            }

        }
        .animation(.easeInOut(duration: 0.6), value: focus)
        .toolbar{
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardToolbarItems()
            }
        }
        .onAppear(){
            focus = .email
        }
        .navigationDestination(isPresented: $isNotEmailConfirmed, destination: {
            RegistrationCodeView(email: $email, password: $password)
        })
        .navigationDestination(isPresented: $forgotPassword, destination: {
            ForgottenPasswordView(isActive1: $forgotPassword)
        })
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
        .environmentObject(ContentViewModel())
}
