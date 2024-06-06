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
                            .frame(height: UIScreen.main.bounds.height)
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
//                                let response = try await APIClient.shared.getClub(clubID: "9a37118f-de7c-46d5-a3bc-384ed6e0b235")
//                                
//                                print(response)
//                            } catch {
//                                print("Error:", error)
//                            }
//                        }
//                    }
//                }
//                .background(.base)

                NetworkStatusView(isConnected: $networkManager.isConnected)
                    .padding(.top, 20)
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
