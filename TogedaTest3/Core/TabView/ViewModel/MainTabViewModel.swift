//
//  MainTabViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation

enum Screen: Equatable {
    case home
    case map
    case add
    case message
    case profile
}

class TabRouter: ObservableObject {
    @Published var screen: Screen = .home
    @Published var oldScreen: Screen = .home
    @Published var isPresenting = false
    
    func change(to screen: Screen) {
        self.screen = screen
    }
}
