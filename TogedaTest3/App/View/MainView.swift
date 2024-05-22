//
//  MainView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 7.05.24.
//

import SwiftUI
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes

struct MainView: View {
    @StateObject var postsViewModel = PostsViewModel()
    @StateObject var userViewModel = UserViewModel()
    @StateObject var navigationManager = NavigationManager()
    @StateObject var locationManager = LocationManager()
    var body: some View {
        MainTabView()
            .environmentObject(postsViewModel)
            .environmentObject(userViewModel)
            .environmentObject(locationManager)
            .environmentObject(navigationManager)
        
    }
}

#Preview {
    MainView()
}
