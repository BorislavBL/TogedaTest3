//
//  IntroView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 11.12.23.
//

import SwiftUI

struct IntroView: View {
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
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    VStack(spacing: 16){
                        NavigationLink(destination: LoginView()){
                            Text("Login")
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .cornerRadius(10)
                                .fontWeight(.semibold)
                        }
                        
                        NavigationLink(destination: RegistrationView()){
                            Text("Register")
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color(.tertiarySystemFill))
                                .cornerRadius(10)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.bottom, 30)
                    
                }
                .padding(.vertical, 32)
                .padding(.horizontal)
                .frame(width: UIScreen.main.bounds.width, height: 400)
                .background(.bar)
                .cornerRadius(10)
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
    }
}

#Preview {
    IntroView()
}
