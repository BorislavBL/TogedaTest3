//
//  ContentView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @StateObject var viewModel = ContentViewModel()
    var body: some View {
        Group {
            if let user = viewModel.currentUser{
               MainTabView(user: user)
           } else {
               Text("IDK")
           }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
