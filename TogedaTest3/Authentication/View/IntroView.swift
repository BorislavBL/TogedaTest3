//
//  IntroView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 11.12.23.
//

import SwiftUI
import AuthenticationServices

struct IntroView: View {
    @StateObject var vm = RegistrationViewModel()
//    @StateObject var googleVM = GoogleAuthService()
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showLogin = false
    @State private var showRegistartion = false
    
    var body: some View {
        NavigationStack{
            ZStack(alignment:.bottom){
                
                Image("intro_image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .scaleEffect(CGSize(width: 1.1, height: 1.1))
                    .rotationEffect(.degrees(-20))
                    .offset(x: UIScreen.main.bounds.width/8.2, y: -UIScreen.main.bounds.height/8.2)
                
                VStack{
                    Text("Connect, explore, and share adventures with new friends on Togeda.")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 30)
                    
                    
                    VStack(spacing: 16){
                        Button{
                            showLogin = true
                        } label:{
                            Text("Login")
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .cornerRadius(10)
                                .fontWeight(.semibold)
                        }
                        
                        Button{
                            showRegistartion = true
                        } label:{
                            Text("Register")
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color(.tertiarySystemFill))
                                .cornerRadius(10)
                                .fontWeight(.semibold)
                        }
//                        Text("Continue with")
//                            .font(.footnote)
//                            .fontWeight(.semibold)
//                            .foregroundStyle(.gray)
//                            .padding(.top, 8)
//                        
//                        HStack(spacing: 16 ){
//                            SignInWithAppleButton(.continue) { request in
//                                request.requestedScopes = [.fullName, .email]
//                            } onCompletion: { result in
//                                switch result {
//                                case .success(let authResults):
//                                    print("Authorization successful.")
//                                    switch authResults.credential{
//                                    case let credential as ASAuthorizationAppleIDCredential :
//                                        let userId = credential.user
//                                        let email = credential.email
//                                        let firstName = credential.fullName?.givenName ?? ""
//                                        let lastName = credential.fullName?.familyName ?? ""
//                                        
//                                        print("firstName: \(firstName) \n lastName: \(lastName) \n userId: \(userId) \n email: \(String(describing: email)) \n ")
//                                    default:
//                                        break
//                                    }
//                                    
//                                case .failure(let error):
//                                    print("Authorization failed: " + error.localizedDescription)
//                                }
//                            }
//                            .labelsHidden()
//                            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
//                            .frame(width: 70, height: 70)
//                            .cornerRadius(10)
//                            
//                            Button{
//                                googleVM.signIn()
//                            } label: {
//                                    Image(colorScheme == .dark ? "google_black" : "google_light")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 20, height: 20)
//                                
//                            }
//                            .frame(width: 70, height: 70)
//                            .background(colorScheme == .dark ? .white : .black)
//                            .foregroundColor(Color("testColor"))
//                            .cornerRadius(10)
//                            .fontWeight(.semibold)
//                        }
                    HStack{
                        Text("By signing up you agree to Togeda's ")
                            .foregroundStyle(.gray) +
                        Text("[Terms of Use]()")
                            .foregroundStyle(.blue) +
                        Text(" and ")
                            .foregroundStyle(.gray) +
                        Text("[Privacy Policy]()")
                            .foregroundStyle(.blue) +
                        Text(".")
                            .foregroundStyle(.gray)
                    }
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                    .padding()
                    }
                    .padding(.bottom, 20)
                    
                }
                .padding(.vertical, 30)
                .padding(.horizontal)
                .frame(width: UIScreen.main.bounds.width)
                .background(.bar)
                .cornerRadius(10)
            }
            .edgesIgnoringSafeArea(.top)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .navigationDestination(isPresented: $showLogin) {
                LoginView()
            }
            .navigationDestination(isPresented: $showRegistartion) {
                RegistrationView()
            }
        }
    }
}

#Preview {
    IntroView()
}
