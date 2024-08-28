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
                ProgressView("Checking authentication...")
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
//                    let sourceTimeZone = TimeZone.current
//
//                    // Create a date formatter with the source time zone
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                    dateFormatter.timeZone = sourceTimeZone
//
//                    // Parse a date string in the source time zone
//                    let dateString = Date()
//                    let sourceDate = dateFormatter.string(from: dateString)
//                    print(sourceDate)
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
