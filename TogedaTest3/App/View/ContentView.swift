//
//  ContentView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: ContentViewModel
    @StateObject var networkManager = NetworkManager()
    
    var body: some View {
        Group {
            ZStack(alignment:.top){
                switch vm.authenticationState {
                case .checking:
                    ProgressView("Checking authentication...")
                case .authenticated:
                    MainView()
                case .unauthenticated:
                    IntroView()
                case .authenticatedNoInformation:
                    RegistrationFullNameView()
                }
                
//                VStack{
//                    Button("Click"){
//                        Task{
//                            do{
//                               let response = try await APIClient.shared.editEvent()
//                                
//                                print(response)
//                            } catch {
//                                print("Error:", error)
//                            }
//                        }
//                    }
//                }
//                .background(.base)

                if !networkManager.isConnected {
                    Text("No Internet Connection")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.vertical)
                        .padding(.horizontal, 30)
                        .background(.red)
                        .cornerRadius(50)
                        .padding(.top)
                }
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ContentViewModel())
    }
}
