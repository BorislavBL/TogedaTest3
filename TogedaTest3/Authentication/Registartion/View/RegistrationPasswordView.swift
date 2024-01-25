//
//  RegistrationPasswordView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.01.24.
//

import SwiftUI

struct RegistrationPasswordView: View {
    enum FocusedField: Hashable{
        case password1, password2
    }
    @ObservedObject var vm: RegistrationViewModel
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var focus: FocusedField?
    @Environment(\.dismiss) var dismiss
    
    @State var confirmPassword: String = ""
    @State private var displayError: Bool = false
    @State private var isPasswordVisible: Bool = false
    
    
    var body: some View {
        VStack {
            Text("Sign In to Your Account")
                .multilineTextAlignment(.center)
                .font(.title).bold()
                .padding(.top, 20)
            
            HStack{
                if isPasswordVisible{
                    TextField("", text: $vm.password)
                } else {
                    SecureField("", text: $vm.password)
                }
                
                Button{
                    isPasswordVisible.toggle()
                } label:{
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundStyle(.gray)
                }
            }
            .placeholder(when: vm.password.isEmpty) {
                Text("Password")
                    .foregroundColor(.secondary)
                    .bold()
            }
            
            .bold()
            .autocapitalization(.none)
            .focused($focus, equals: .password1)
            .onSubmit {
                focus = .password2
            }
            .padding(10)
            .frame(minWidth: 80, minHeight: 47)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.top, 20)
            
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
            .padding(10)
            .frame(minWidth: 80, minHeight: 47)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.top, 2)
            .padding(.bottom, 15)
            
            if displayError && !isValidPassword(vm.password) {
                WarningTextComponent(text: "Make sure the password is at lest 6 characters long, contains letters and digits and has at lest one capital letter.")
                    .padding(.bottom, 15)
            } else if displayError &&  confirmPassword != vm.password {
                WarningTextComponent(text: "The two passwords do not match.")
            }
            
            
            Spacer()
            
            NavigationLink(destination: RegistrationFullNameView(vm: vm)){
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .cornerRadius(10)
                    .fontWeight(.semibold)
            }
            .disableWithOpacity(!isValidPassword(vm.password) || !samePassword)
            .onTapGesture {
                if !isValidPassword(vm.password) || !samePassword{
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
    
    func isValidPassword(_ password: String) -> Bool {
        let hasLetters = password.rangeOfCharacter(from: .letters) != nil
        let hasNumbers = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasCapitalLetter = password.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
        let isLongEnough = password.count >= 6
        
        return hasLetters && hasNumbers && hasCapitalLetter && isLongEnough
    }
    
    var samePassword: Bool {
        return confirmPassword == vm.password
    }
    
}
#Preview {
    RegistrationPasswordView(vm: RegistrationViewModel())
}
