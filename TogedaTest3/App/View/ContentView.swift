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

    @EnvironmentObject var networkManager: NetworkManager
    @Environment(\.openURL) var openURL
    
    var body: some View {
        
        ZStack(alignment:.top){
            switch vm.authenticationState {
            case .checking:
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
            case .update:
                UpdateAppView()
            }
            
            
//            VStack{
//                Button("Click1"){
//                    if isGoogleMapsInstalled() {
//                        print("Google Maps is installed.")
//                        // Open Google Maps with a location or perform other actions
//                        openGoogleMaps(latitude: 37.4220, longitude: -122.0841)
//                    } else {
//                        print("Google Maps is not installed.")
//                        // Provide an alternative option, such as opening a web map
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
            .environmentObject(NetworkManager())


    }
}
