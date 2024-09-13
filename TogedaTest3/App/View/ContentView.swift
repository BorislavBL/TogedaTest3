//
//  ContentView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: ContentViewModel
    @EnvironmentObject var navManager: NavigationManager

    @StateObject var networkManager = NetworkManager()
    
    var body: some View {
        
        ZStack(alignment:.top){
            switch vm.authenticationState {
            case .checking:
//                ProgressView("Checking authentication...")
                Text("Togeda")
                    .font(.title)
                    .bold()
                    .frame(height: UIScreen.main.bounds.height)
            case .authenticated:
                MainView()
            case .unauthenticated:
                IntroView()
                    .onAppear(){
                        navManager.toDefault()
                    }
            case .authenticatedNoInformation:
                RegistrationFullNameView()
            }
            
            
//            VStack{
//                Button("Click"){
//                    Task{
//                        if let response = try await APIClient.shared.checkForPaidEvents() {
//                            print("The string:",response.data)
//                            if let bool = Bool(response.data) {
//                                print("The value: \(bool)")
//                                if bool {
//                                    print("hahha true")
//                                } else {
//                                    print("hahha false")
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            .background(.base)
            
//            NetworkStatusView(isConnected: $networkManager.isConnected)
//                .padding(.top, 20)
        }
        .fullScreenCover(isPresented: $networkManager.isDisconected) {
            NoInternetConnectionView()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ContentViewModel())
            .environmentObject(NavigationManager())

    }
}
