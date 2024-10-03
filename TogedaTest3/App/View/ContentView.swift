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
//                Button("Click"){
//                    print("\(vm.getBuildNumber()) : \(vm.getAppVersion())")
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
