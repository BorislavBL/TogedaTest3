//
//  UserViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 28.09.23.
//

import SwiftUI

@MainActor
class UserViewModel: ObservableObject {
    @Published var currentUser: Components.Schemas.UserInfoDto?
    
    init(){
//        self.retryFetchUser()
//        Task{
//            do {
//                try await fetchCurrentUser()
//                print("End user fetch")
//            } catch {
//                // Handle the error if needed
//                print("Error fetching data: \(error)")
//            }
//        }
    }
    
    func retryFetchUser() {
        Task {
            while true {
                do {
                    try await fetchCurrentUser()
                    print("End user fetch")
                    break // Exit loop if fetchPosts succeeds
                } catch {
                    // Handle the error if needed
                    print("Error fetching data: \(error)")
                    try await Task.sleep(nanoseconds: 20_000_000_000)
                }
            }
        }
    }
    
    func fetchCurrentUser() async throws{
        currentUser = try await APIClient.shared.getCurrentUserInfo()
    }
}
