//
//  PhoneNumberCodeView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 27.02.24.
//

import SwiftUI

struct PhoneNumberCodeView: View {
    @Binding var code: String
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var keyIsFocused: Bool
    @Environment(\.dismiss) var dismiss
    
    @State private var displayError: Bool = false
    @State private var isActive: Bool = false
    
    @State private var errorMessage: String?
    
    var resendFunc: () -> Void
    var submitFunc: () -> Void
    
    var body: some View {
        VStack {
            Text("Please enter the verification code.")
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
                resendFunc()
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
                submitFunc()
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
                if code.count < 6 {
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
    PhoneNumberCodeView(code: .constant("123456"), resendFunc: {}, submitFunc: {})
}
