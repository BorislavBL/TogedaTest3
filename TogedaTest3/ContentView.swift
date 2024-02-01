//
//  ContentView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @StateObject var networkManager = NetworkManager()
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @StateObject var viewModel = ContentViewModel()
    
    @StateObject var postsViewModel = PostsViewModel()
    @StateObject var userViewModel = UserViewModel()
    
    var body: some View {
        Group {
            ZStack(alignment:.top){
//                if let user = viewModel.currentUser{
//                    MainTabView(user: user)
//                        .environmentObject(locationManager)
//                        .environmentObject(postsViewModel)
//                        .environmentObject(userViewModel)
//                } else {
                    IntroView()
//                }
                
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
    }
}
