//
//  ForgottenPasswordView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 23.08.24.
//

import SwiftUI

struct ForgottenPasswordView: View {
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var focus: Bool
    @Environment(\.dismiss) var dismiss
    @State var email: String = ""
    @State private var displayError: Bool = false
    @State private var errorMessage: String?
    @State private var confirmPassword: Bool = false
    @Binding var isActive1: Bool

    
    @EnvironmentObject var mainVm: ContentViewModel
    
    @State var userId: String = ""
    
    var body: some View {
        VStack {
            Text("Please enter your email and a code will be send to you!")
                .multilineTextAlignment(.center)
                .font(.title).bold()
                .padding(.top)
            
            TextField("", text: $email)
                .placeholder(when: email.isEmpty) {
                    Text("Email")
                        .foregroundColor(.secondary)
                        .bold()
                }
                .bold()
                .autocapitalization(.none)
                .focused($focus)
                .keyboardType(.emailAddress)
                .padding(10)
                .frame(minWidth: 80, minHeight: 47)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(.top, 20)
            
            if displayError && !isValidEmail(testStr: email) {
                WarningTextComponent(text: "Please enter a valid email.")
                    .padding(.bottom, 15)
            }

            if let message = errorMessage {
                WarningTextComponent(text: message)
                    .padding(.bottom, 15)
            }
            
            Spacer()
            
            Button{
                errorMessage = nil
                Task{
                    try await AuthService.shared.forgotPassword(email: email) { success, error in
                        if let success = success, success {
                            confirmPassword = true
                        } else if let errorMessage = error {
                            DispatchQueue.main.async{
                                print("Error on the way")
                                self.errorMessage = errorMessage
                            }
                        }
                    }
                }
            } label: {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .cornerRadius(10)
                    .fontWeight(.semibold)
            }
            .disableWithOpacity(!isValidEmail(testStr: email) || email.isEmpty)
            .onTapGesture {
                if !isValidEmail(testStr: email) || email.isEmpty {
                    displayError.toggle()
                }
            }
            
        }
        .animation(.easeInOut(duration: 0.6), value: focus)
        .padding(.horizontal)
        .toolbar{
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardToolbarItems()
            }
        }
        .onAppear(){
            focus = true
        }
        .padding(.vertical)
        .navigationDestination(isPresented: $confirmPassword, destination: {
            ConfirmForgottenPasswordView(isActive1: $isActive1, isActive2: $confirmPassword, email: email)
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
}


#Preview {
    ForgottenPasswordView(isActive1: .constant(true))
}
