//
//  ChangePasswordView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 26.09.24.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @State private var displayError: Bool = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    @State var oldPassword: String = ""
    
    enum FocusedField: Hashable{
        case password1, password2, password3
    }

    @FocusState private var focus: FocusedField?

    @State var newPassword: String = ""

    @State var confirmNewPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    
    
    var body: some View {
        VStack {
            Text("Change your password.")
                .multilineTextAlignment(.center)
                .font(.title).bold()
                .padding(.top, 20)
            
            HStack{
                if isPasswordVisible{
                    TextField("", text: $oldPassword)
                } else {
                    SecureField("", text: $oldPassword)
                }
                
                Button{
                    isPasswordVisible.toggle()
                } label:{
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundStyle(.gray)
                }
            }
            .placeholder(when: oldPassword.isEmpty) {
                Text("Old Password")
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
                    TextField("", text: $newPassword)
                } else {
                    SecureField("", text: $newPassword)
                }
                
                Button{
                    isPasswordVisible.toggle()
                } label:{
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundStyle(.gray)
                }
            }
            .placeholder(when: newPassword.isEmpty) {
                Text("New Password")
                    .foregroundColor(.secondary)
                    .bold()
            }
            
            .bold()
            .autocapitalization(.none)
            .focused($focus, equals: .password2)
            .submitLabel(.next)
            .onSubmit {
                focus = .password3
            }
            .padding(10)
            .frame(minWidth: 80, minHeight: 47)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            
            HStack{
                if isPasswordVisible{
                    TextField("", text: $confirmNewPassword)
                } else {
                    SecureField("", text: $confirmNewPassword)
                }
                
                Button{
                    isPasswordVisible.toggle()
                } label:{
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundStyle(.gray)
                }
            }
            .placeholder(when: confirmNewPassword.isEmpty) {
                Text("Confirm New Password")
                    .foregroundColor(.secondary)
                    .bold()
            }
            .bold()
            .focused($focus, equals: .password3)
            .submitLabel(.done)
            .onSubmit {
                hideKeyboard()
            }
            .padding(10)
            .frame(minWidth: 80, minHeight: 47)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.top, 2)
            .padding(.bottom, 15)
            
            if displayError && confirmNewPassword != newPassword {
                WarningTextComponent(text: "The two passwords do not match.")
            } else if let message = errorMessage, !message.isEmpty, displayError {
                WarningTextComponent(text: message)
            } else if displayError && differentNewPassword {
                WarningTextComponent(text: "The new password must be different than the old one.")
            }

            Spacer()
            
            Button{
                Task{
                    try await APIClient.shared.changePassword(old: oldPassword, new: newPassword){ success, error in
                        DispatchQueue.main.async {
                            if let success = success, success {
                                self.isLoading = false
                                dismiss()
                            } else if let errorMessage = error {
                                if errorMessage.lowercased().contains("user already exists".lowercased()) {
                                    self.errorMessage = "User already exists."
                                    
                                } else {
                                    self.errorMessage = errorMessage
 
                                }
                                self.isLoading = false
                                
                            } else {
                                self.isLoading = false
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
            .disableWithOpacity(!samePassword || !validatePassword(password: newPassword) || !differentNewPassword)
            .onTapGesture {
                if !samePassword || !validatePassword(password: newPassword) || !differentNewPassword {
                    displayError.toggle()
                }
                
                let _ = validatePassword(password: newPassword)
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
        if confirmNewPassword == newPassword && !newPassword.isEmpty{
            return true
        } else {
            return false
        }
    }
    
    var differentNewPassword: Bool {
        if oldPassword != newPassword{
            return true
        } else {
            return false
        }
    }
    
    func validatePassword(password: String) -> Bool{
        let lengthRequirement = password.count >= 8
        let uppercaseRequirement = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let lowercaseRequirement = password.range(of: "[a-z]", options: .regularExpression) != nil
        let numberRequirement = password.range(of: "[0-9]", options: .regularExpression) != nil
        let specialCharacterRequirement = password.range(of: "[!@#$&*]", options: .regularExpression) != nil
        
        if lengthRequirement && uppercaseRequirement && lowercaseRequirement && numberRequirement && specialCharacterRequirement {
            DispatchQueue.main.async{
                self.errorMessage = ""
            }
            return true
        } else {
            DispatchQueue.main.async{
                self.errorMessage = """
            Password must be at least 8 characters long, contain at least one uppercase letter, one lowercase letter, one number, and one special character.
            """
            }
            
            return false
        }
    }
}

#Preview {
    ChangePasswordView()
}
