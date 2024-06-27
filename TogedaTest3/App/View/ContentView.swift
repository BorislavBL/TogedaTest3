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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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
//                CropTestView()
//                CheckoutView()
//                
//                VStack{
//                    Button("Click"){
//                        Task{
//                            if let request = try await APIClient.shared.getPaymentSheet(postId: "d9a5945b-35b9-4458-82c6-6d530cbce4fb"){
//                                    print("\(request)")
//                            }
//                            
//                        }
//                        
////                        NotificationsManager().registerForPushNotifications()
//
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
