//
//  Test2View.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.11.23.
//

import SwiftUI
import MapKit

struct Test2View: View {
    var userId = "53e4d8d2-b071-70bb-5d32-caf039f7adbc"
    @StateObject var userVM = UserViewModel()
    @State var user: Components.Schemas.UserInfoDto?
    @StateObject var viewModel = ProfileViewModel()
    @EnvironmentObject var websocket: WebSocketManager
    @State var triggerCounter: Int = 0

    var body: some View {
        VStack{
            Text("\(user?.currentFriendshipStatus?.rawValue), \(triggerCounter)")
                .onChange(of: websocket.newNotification){ old, new in
                    print("Triggered 1")
                    if let not = new {
                        print("triggered 2")
                        
                        print("\(not)")
                        
                        if not.alertBodyFriendRequestAccepted != nil {
                            print("Its here")
                            user?.currentFriendshipStatus = .FRIENDS
                        } else if not.alertBodyFriendRequestReceived != nil {
                            print("or here here")
                            user?.currentFriendshipStatus = .RECEIVED_FRIEND_REQUEST
                        }
                        
//                        if triggerCounter == 0 {
//                            user?.currentFriendshipStatus = .FRIENDS
//                        } else if triggerCounter == 1 {
//                            user?.currentFriendshipStatus = .NOT_FRIENDS
//                        }
                        triggerCounter += 1
                    }
                }
                .onAppear(){
                    Task{
                        do {
                            if let response = try await APIClient.shared.getUserInfo(userId: userId) {
                                DispatchQueue.main.async {
                                    self.user = response
                                    
                                }
                            }
                            
                        } catch {
                            print("Error fetching user posts: \(error)")
                        }
                    }
                }
        }
    }
}

#Preview {
    Test2View()
        .environmentObject(WebSocketManager())
}

