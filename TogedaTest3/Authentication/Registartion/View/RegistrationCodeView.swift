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
    var body: some View {
        VStack {
            Text("Please enter the code you receive.")
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
                    if vm.code.count > 4 {
                        vm.code = String(vm.code.prefix(4))
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
            
            Button{
                vm.code = ""
            } label: {
                HStack(alignment: .top, content: {
                    Image(systemName: "gobackward")
                    Text("Resend the code")
                        .bold()
                    
                })
                .foregroundStyle(.gray)
            }
            
            Spacer()
            
            NavigationLink(destination: RegistrationEmailView()){
                Text("Complete")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .cornerRadius(10)
                    .fontWeight(.semibold)
            }
            .disableWithOpacity(vm.code.count < 4)
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
