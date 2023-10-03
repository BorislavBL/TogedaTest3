//
//  ContentViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation
import SwiftUI

class ContentViewModel: ObservableObject {
    @AppStorage("userId") var userId: String = ""
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @Published var currentUser: User?
    
    init(){

        setupSubscribers()
    }
    
    func setupSubscribers(){
        currentUser = User.MOCK_USERS[0]
        userId = User.MOCK_USERS[0].id
        isLoggedIn = true
        
    }
}
