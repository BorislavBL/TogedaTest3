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
    
    @State private var isTimerActive: Bool = false
    @State private var remainingTime: Int = 30
    
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
            
            if isTimerActive {
                Text("Resend code in \(remainingTime) seconds")
                    .foregroundStyle(.gray)
                    .padding(.bottom, 15)
            } else {
                Button(action: {
                    code = ""
                    Task {
                        if let success = try await AuthService.shared.resendEmailConfirmationCode(email: email) {
                            if success {
                                startTimer()
                            }
                        }
                    }
                }) {
                    HStack(alignment: .top, content: {
                        Image(systemName: "gobackward")
                        Text("Resend the code")
                            .bold()
                    })
                    .foregroundStyle(.gray)
                }
            }
            
            Spacer()
            
            Button{
                Task {
                    try await AuthService.shared.confirmSignUp(code: code, userId: email) { success, error in
                        if let success = success, success {
                            Task{
                                try await AuthService.shared.login(email: email, password: password) { response, error  in
                                    if let response = response {
                                        print("Success")
                                        let refershToken = KeychainManager.shared.saveOrUpdate(item: response.refreshToken, account: userKeys.refreshToken.toString, service: userKeys.service.toString)
                                        let accessToken = KeychainManager.shared.saveOrUpdate(item: response.accessToken, account: userKeys.accessToken.toString, service: userKeys.service.toString)
                                        let token = getDecodedJWTBody(token: response.accessToken )
                                        if let userId = token?.username {
                                            let savedUserIdData = KeychainManager.shared.saveOrUpdate(item: userId, account: userKeys.userId.toString, service: userKeys.service.toString)
                                            print(savedUserIdData ? "Token saved/updated successfully" : "Failed to save/update token")
                                        }
                                        Task{
                                            await mainVm.validateTokensAndCheckState()
                                        }
                                    } else if let message = error {
                                        print(message)
                                    }
                                }
                            }
                        } else if let errorMessage = error {
                            DispatchQueue.main.async {
                                self.errorMessage = errorMessage
                            }
                        }
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
        .onAppear(){
            code = ""
            Task {
                if let success = try await AuthService.shared.resendEmailConfirmationCode(email: email) {
                    if success {
                        
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {dismiss()}) {
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
    
    // Timer function
    func startTimer() {
        remainingTime = 30
        isTimerActive = true
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                timer.invalidate()
                isTimerActive = false
            }
        }
    }
}

#Preview {
    RegistrationCodeView(email: .constant(""), password: .constant(""))
        .environmentObject(ContentViewModel())
}
