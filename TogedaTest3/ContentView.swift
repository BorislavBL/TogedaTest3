//
//  ContentView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @StateObject var viewModel = ContentViewModel()
    var body: some View {
        Group {
            if let user = viewModel.currentUser{
               MainTabView(user: user)
                    .environmentObject(locationManager)
           } else {
               Text("IDK")
           }
        }
//        .alert("Please enable your Location", isPresented: $locationManager.showLocationServicesAlert){
//            Button("OK"){
//                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
//            }
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
