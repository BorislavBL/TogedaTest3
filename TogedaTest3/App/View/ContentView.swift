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
        
        ZStack(alignment:.top){
            switch vm.authenticationState {
            case .checking:
                ProgressView("Checking authentication...")
                    .frame(height: UIScreen.main.bounds.height)
            case .authenticated:
                MainView()
                //                    Test2View()
            case .unauthenticated:
                IntroView()
            case .authenticatedNoInformation:
                RegistrationFullNameView()
            }
            
            
            VStack{
                Button("Click"){
                    print(TimeZone.current)
                    print(Date())
                }
            }
            .background(.base)
            
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
    }
}
