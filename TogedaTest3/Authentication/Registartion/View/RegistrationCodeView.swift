//
//  RegistrationCodeView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 14.12.23.
//

import SwiftUI
import AWSCognitoIdentityProvider

struct RegistrationCodeView: View {
    @EnvironmentObject var mainVm: ContentViewModel
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var keyIsFocused: Bool
    @Environment(\.dismiss) var dismiss
    
    @State private var displayError: Bool = false
    
    @State private var errorMessage: String?
    
    @State var code: String = ""
    @Binding var email: String
    @Binding var password: String
    
    var body: some View {
        VStack {
            Text("Please enter the verification code you have received on your email.")
                .multilineTextAlignment(.center)
                .font(.title).bold()
                .padding(.top, 20)
            
            TextField("", text: $code)
                .placeholder(when: code.isEmpty) {
                    Text("Code")
                        .foregroundColor(.secondary)
                        .bold()
                }
                .onChange(of: code) { oldValue, newValue in
                    if code.count > 6 {
                        code = String(code.prefix(6))
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
                code = ""
                AuthClient.shared.resendConfirmationCode(email: email) { success, error in
                    if success {
                        
                    } else if let errorMessage = error {
                        print("Error:", errorMessage)
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
                AuthClient.shared.confirmSignUp(email: email, code: code) { success, error in
                    if success {
                        AuthClient.shared.login(email: email, password: password) { success, emailNotConfirmed, error  in
                            if success {
                                print("Success")
                                mainVm.checkAuthStatus()
                            } else if let message = error {
                                print(message)
                                if emailNotConfirmed{
                                    print("Email not confirmed")
                                }
                            }
                        }
                    } else if let errorMessage = error {
                        self.errorMessage = errorMessage
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
            .disableWithOpacity(code.count < 6)
            .onTapGesture {
                if code.count < 4 {
                    displayError.toggle()
                }
            }
            
        }
        .animation(.easeInOut(duration: 0.6), value: keyIsFocused)
        .padding(.horizontal)
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
}

#Preview {
    RegistrationCodeView(email: .constant(""), password: .constant(""))
        .environmentObject(ContentViewModel())
}
