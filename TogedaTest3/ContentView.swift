//
//  ContentView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @StateObject var networkManager = NetworkManager()
    @StateObject var postsViewModel = PostsViewModel()
    @StateObject var userViewModel = UserViewModel()
    
    var body: some View {
        Group {
            ZStack(alignment:.top){
                switch viewModel.authenticationState {
                    case .checking:
                        ProgressView("Checking authentication...")
                    case .authenticated:
                        MainTabView()
                            .environmentObject(postsViewModel)
                            .environmentObject(userViewModel)
                    case .unauthenticated:
                        IntroView()
                }
                
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
