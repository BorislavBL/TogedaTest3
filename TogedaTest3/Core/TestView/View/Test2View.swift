////
////  Test2View.swift
////  TogedaTest3
////
////  Created by Borislav Lorinkov on 3.11.23.
////
//
//import SwiftUI
//import MapKit
//
//struct Test2View: View {
//    @StateObject var userVM = UserViewModel()
//    var body: some View {
//        VStack{
//            Button {
//                if let currentUser = userVM.currentUser{
//                    chatVM.sendMessage(senderId: currentUser.id, chatId: "7ac08bf6-5f6f-4136-bb76-3d4b7b96ddb8", content: "Test meessage" , type: .NORMAL)
//                }
//            } label: {
//                Text("Click")
//            }
//        }
//        .onChange(of: userVM.currentUser) {
//            chatVM.currentUserId = userVM.currentUser?.id
//        }
//        .onAppear(){
//            Task{
//                do {
//                    try await userVM.fetchCurrentUser()
//                    print("End user fetch")
//                } catch {
//                    // Handle the error if needed
//                    print("Error fetching data: \(error)")
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    Test2View()
//}
