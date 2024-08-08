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
//                    Test2View()
                case .unauthenticated:
                    IntroView()
                case .authenticatedNoInformation:
                    RegistrationFullNameView()
                }

                
//                VStack{
//                    Button("Click"){
//                        let post: Components.Schemas.CreatePostDto = .init(title: "!234", images: ["https://togeda-profile-photos.s3.eu-central-1.amazonaws.com/037FD054-0912-4D99-990E-7BBFEBFF8065.jpeg"], location: Components.Schemas.BaseLocation.init(
//                            name: "Sofia, Bulgaria",
//                            address:"Something",
//                            city: "Sofia",
//                            country: "Bulgaria",
//                            latitude: 42.6977,
//                            longitude: 23.3219
//                        ), interests: [], payment: 0, accessibility: .PUBLIC, askToJoin: false)
//                        Task{
//                            do{
//                                try await APIClient.shared.createEvent(body: post){ response, error in
//                                    print("\(error)")
//                                }
//                            } catch {
//                                print(error)
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
