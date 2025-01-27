//
//  JoinRequestView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.10.23.
//

import SwiftUI
import StripePaymentSheet

struct JoinRequestView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var postsViewModel: PostsViewModel
    @EnvironmentObject var chatManager: WebSocketManager
    @EnvironmentObject var activityVM: ActivityViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var locationManager: LocationManager
    @Binding var post: Components.Schemas.PostResponseDto
    @EnvironmentObject var navManager: NavigationManager
    @Binding var isActive: Bool
    var refreshParticipants: () -> ()
    @Environment(\.openURL) private var openURL
    @StateObject var paymentVM = StripeAccountViewModel()
    @State var distance: Int = 0
    @State var showConfirmLocationError: Bool = false
    
    @State var loadingState: LoadingCases = .loaded
    
    var body: some View {
        VStack(spacing: 30){
            if loadingState == .loaded {
                if isOwner {
                    if post.status == .HAS_STARTED {
                        Text("How would you like to proceed?")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Button {
                            Task{
                                loadingState = .loading
                                defer{ loadingState = .loaded }
                                if try await APIClient.shared.startOrEndEvent(postId: post.id, action: .END) != nil {
                                    if let response = try await APIClient.shared.getEvent(postId: post.id){
                                        if let index = postsViewModel.feedPosts.firstIndex(where: { $0.id == post.id }) {
                                            postsViewModel.feedPosts.remove(at: index)
                                        }
                                        
                                        if let index = activityVM.activityFeed.firstIndex(where: { $0.post?.id == post.id }) {
                                            activityVM.activityFeed.remove(at: index)
                                        }
                                        
                                        post = response
                                        
                                        isActive = false
                                        
                                    }
                                }
                            }
                        } label: {
                            Text("Stop the Event")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .cornerRadius(10)
                        }
                        
                    } else if post.status == .NOT_STARTED {
                        if post.fromDate != nil {
                            if post.participantsCount > 1 {
                                if post.payment <= 0 {
                                    Text("Already \(post.participantsCount) people have joined your event! Are you sure you want to delete it?")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                } else {
                                    Text("Sorry, you can't delete a paid event with participants. To cancel the activity, please discuss it with your participants through the chat.")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                }
                            } else {
                                Text("Would you like to delete the event?")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            
                            if post.payment <= 0 || post.participantsCount < 2{
                                Button {
                                    Task{
                                        loadingState = .loading
                                        defer{ loadingState = .loaded }
                                        if try await APIClient.shared.deleteEvent(postId: post.id) != nil {
                                            if let index = postsViewModel.feedPosts.firstIndex(where: { $0.id == post.id }) {
                                                postsViewModel.feedPosts.remove(at: index)
                                            }
                                            
                                            if let index = activityVM.activityFeed.firstIndex(where: { $0.post?.id == post.id }) {
                                                activityVM.activityFeed.remove(at: index)
                                            }
                                            isActive = false
                                            if navManager.selectionPath.count > 0 {
                                                navManager.selectionPath.removeLast(1)
                                            }
                                        }
                                    }
                                } label: {
                                    Text("Delete the Event")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 60)
                                        .background(Color("blackAndWhite"))
                                        .foregroundColor(Color("testColor"))
                                        .cornerRadius(10)
                                }
                            } else {
                                Text("Delete the Event")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                                    .disableWithOpacity(true)
                            }
                        } else {
                            Text("Would you like to start the event?")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Button {
                                Task{
                                    loadingState = .loading
                                    defer{ loadingState = .loaded }
                                    if try await APIClient.shared.startOrEndEvent(postId: post.id, action: .START) != nil {
                                        if let response = try await APIClient.shared.getEvent(postId: post.id){
                                            postsViewModel.localRefreshEventOnAction(post: response)
                                            activityVM.localRefreshEventOnAction(post: response)
                                            post = response
                                            isActive = false
                                        }
                                    }
                                }
                            } label: {
                                Text("Start the Event")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                            }
                        }
                    } else if post.status == .HAS_ENDED {
                        Text("The event has ended.")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("Ended")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                    }
                    else {
                        Text("The event has ended.")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("Ended")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                    }
                    
                } else {
                    if post.status == .HAS_STARTED {
                        if post.currentUserStatus == .PARTICIPATING && post.needsLocationalConfirmation && post.currentUserArrivalStatus != .ARRIVED {
                            if showConfirmLocationError {
                                if distance < 1 {
                                    Text("\(distance * 1000)m/50m")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                } else {
                                    Text("\(distance)km/50m")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                }
                            } else {
                                Text("Confirm your location.")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                            }
                            
                            
                            Button {
                                if let location = getUserLocationCords(){
                                    let distance = calculateDistance(lat1: location.coordinate.latitude, lon1: location.coordinate.longitude, lat2: post.location.latitude, lon2: post.location.longitude)
                                    self.distance = Int(distance.rounded())
                                    if distance * 1000 <= 50 {
                                        Task{
                                            if let response = try await APIClient.shared.confirmUserLocation(postId: post.id) {
                                                post.currentUserArrivalStatus = .ARRIVED
                                                postsViewModel.localRefreshEventOnAction(post: post)
                                            }
                                        }
                                    } else {
                                        withAnimation {
                                            showConfirmLocationError = true
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                                            withAnimation {
                                                showConfirmLocationError = false
                                            }
                                        })
                                    }
                                }
                            } label: {
                                Text("Confirm Arrival")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                            }
                        } else {
                            Text("The event have already started...")
                                .font(.headline)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Button {
                                
                            } label: {
                                Text("Ongoing")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                            }
                        }
                    } else if post.status == .NOT_STARTED {
                        if post.currentUserStatus == .PARTICIPATING {
                            if post.payment <= 0 {
                                Text("Are you sure you want to leave?")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("You cannot leave an event you’ve paid for. For refunds, please contact the event organizer directly. We are not responsible for processing any refunds.")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                            }
                            
                            if post.payment <= 0 {
                                Button {
                                    Task{
                                        loadingState = .loading
                                        defer{ loadingState = .loaded }
                                        if try await APIClient.shared.leaveEvent(postId: post.id) != nil {
                                            if let response = try await APIClient.shared.getEvent(postId: post.id){
                                                postsViewModel.localRefreshEventOnAction(post: response)
                                                activityVM.localRefreshEventOnAction(post: response)
                                                post = response
                                                refreshParticipants()
                                                userViewModel.removePost(post: response)
                                                if let chatRoomId = post.chatRoomId {
                                                    chatManager.allChatRooms.removeAll(where: {$0.id == chatRoomId})
                                                }
                                                isActive = false
                                            }
                                        }
                                    }
                                } label: {
                                    Text("Leave")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 60)
                                        .background(Color("blackAndWhite"))
                                        .foregroundColor(Color("testColor"))
                                        .cornerRadius(10)
                                }
                            } else {
                                Text("Leave")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                                    .disableWithOpacity(true)
                            }
                        } else if post.currentUserStatus == .IN_QUEUE {
                            Text("Are you sure you want to cancel your request?")
                                .font(.headline)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Button {
                                Task{
                                    loadingState = .loading
                                    defer{ loadingState = .loaded }
                                    if try await APIClient.shared.cancelJoinRequestForEvent(postId: post.id) != nil {
                                        if let response = try await APIClient.shared.getEvent(postId: post.id){
                                            postsViewModel.localRefreshEventOnAction(post: response)
                                            activityVM.localRefreshEventOnAction(post: response)
                                            post = response
                                            isActive = false
                                        }
                                    }
                                }
                            } label: {
                                Text("Cancel")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                            }
                        } else {
                            
                            if post.payment <= 0 {
                                if post.askToJoin{
                                    Text("Submit a request to join and wait for the organizer's approval!")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                } else if let max = post.maximumPeople, max <= post.participantsCount{
                                    Text("Oops, the event is packed! But don’t worry—you can hop on the waitlist and snag a spot if someone changes their plans!")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                } else {
                                    Text("Join the Event!")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                }
                                
                                Button {
                                    Task{
                                        loadingState = .loading
                                        defer{ loadingState = .loaded }
                                        if try await APIClient.shared.joinEvent(postId: post.id) != nil {
                                            if let response = try await APIClient.shared.getEvent(postId: post.id){
                                                postsViewModel.localRefreshEventOnAction(post: response)
                                                activityVM.localRefreshEventOnAction(post: response)
                                                
                                                refreshParticipants()
                                                userViewModel.addPost(post: response)
                                                
                                                post = response
                                                isActive = false
                                            }
                                        }
                                    }
                                } label: {
                                    Text("Join")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 60)
                                        .background(Color("blackAndWhite"))
                                        .foregroundColor(Color("testColor"))
                                        .cornerRadius(10)
                                }
                                
                            } else {
                                if let max = post.maximumPeople, max <= post.participantsCount{
                                    Text("Oh no, tickets are sold out! But keep an eye out—if someone cancels, you’ll have the chance to grab their spot. Stay ready to snag a ticket if it opens up!")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Waiting...")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 60)
                                        .background(Color("blackAndWhite"))
                                        .foregroundColor(Color("testColor"))
                                        .cornerRadius(10)
                                } else {
                                    if let error = paymentVM.error {
                                        Text("Error: \(error).")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                    } else {
                                        if post.askToJoin {
                                            Text("Request a ticket, and once the organizer approves, your ticket will be automatically purchased!")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                        } else {
                                            Text("Buy a ticket and join the Event!")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                        }
                                    }
                                    
                                    
                                    VStack {
                                        if let paymentSheet = paymentVM.paymentSheet {
                                            PaymentSheet.PaymentButton(
                                                paymentSheet: paymentSheet,
                                                onCompletion: paymentVM.onPaymentCompletion
                                            ) {
                                                
                                                if let result = paymentVM.paymentResult {
                                                    switch result {
                                                    case .completed:
                                                        Text("Payment complete.")
                                                            .fontWeight(.semibold)
                                                            .frame(maxWidth: .infinity)
                                                            .frame(height: 60)
                                                            .background(Color("blackAndWhite"))
                                                            .foregroundColor(Color("testColor"))
                                                            .cornerRadius(10)
                                                            .onAppear(){
                                                                Task{
                                                                    loadingState = .loading
                                                                    defer{ loadingState = .loaded }
                                                                    if let response = try await APIClient.shared.getEvent(postId: post.id){
                                                                        postsViewModel.localRefreshEventOnAction(post: response)
                                                                        activityVM.localRefreshEventOnAction(post: response)
                                                                        
                                                                        refreshParticipants()
                                                                        
                                                                        post = response
                                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                                            
                                                                            isActive = false
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                            }
                                                    case .failed(let error):
                                                        Text("Payment failed.")
                                                            .fontWeight(.semibold)
                                                            .frame(maxWidth: .infinity)
                                                            .frame(height: 60)
                                                            .background(Color("blackAndWhite"))
                                                            .foregroundColor(Color("testColor"))
                                                            .cornerRadius(10)
                                                            .onAppear(){
                                                                paymentVM.error = error.localizedDescription
                                                            }
                                                    case .canceled:
                                                        Text("Payment canceled.")
                                                            .fontWeight(.semibold)
                                                            .frame(maxWidth: .infinity)
                                                            .frame(height: 60)
                                                            .background(Color("blackAndWhite"))
                                                            .foregroundColor(Color("testColor"))
                                                            .cornerRadius(10)
                                                            .onAppear(){
                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                                    isActive = false
                                                                }
                                                            }
                                                    }
                                                } else {
                                                    Text("Buy \(post.payment, specifier: "%.2f")")
                                                        .fontWeight(.semibold)
                                                        .frame(maxWidth: .infinity)
                                                        .frame(height: 60)
                                                        .background(Color("blackAndWhite"))
                                                        .foregroundColor(Color("testColor"))
                                                        .cornerRadius(10)
                                                    
                                                }
                                            }
                                        }
                                        else {
                                            Text("Loading…")
                                                .fontWeight(.semibold)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 60)
                                                .background(Color("blackAndWhite"))
                                                .foregroundColor(Color("testColor"))
                                                .cornerRadius(10)
                                            
                                        }
                                        
                                    }.onAppear {
                                        paymentVM.eventID = post.id
                                        paymentVM.preparePaymentSheet()
                                    }
                                }
                            }
                            
                            
                        }
                        
                    } else if post.status == .HAS_ENDED {
                        Text("Ended")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                    }
                    else {
                        if post.payment <= 0 {
                            if post.askToJoin{
                                Text("Submit a request to join and wait for the organizer's approval!")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("Join the Event!")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        
                        Button {
                            Task{
                                loadingState = .loading
                                defer{ loadingState = .loaded }
                                if try await APIClient.shared.joinEvent(postId: post.id) != nil {
                                    if let response = try await APIClient.shared.getEvent(postId: post.id){
                                        postsViewModel.localRefreshEventOnAction(post: response)
                                        activityVM.localRefreshEventOnAction(post: response)
                                        post = response
                                        userViewModel.addPost(post: response)
                                        isActive = false
                                    }
                                }
                            }
                        } label: {
                            Text("Join")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .cornerRadius(10)
                        }
                    }
                }
            } else {
                Text("Your request is being processed.")
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                loadingButton()
            }
            
        }
        .onAppear() {
            if let from = post.fromDate, from < Date() {
                post.status = .HAS_STARTED
            }
        }
        .padding()
        .presentationDetents([.height(250)])
        

    }
    
    
    @ViewBuilder
    func loadingButton() -> some View {
        Text("Loading...")
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color("blackAndWhite"))
            .foregroundColor(Color("testColor"))
            .cornerRadius(10)
    }
    
    var isOwner: Bool {
        if let user = userViewModel.currentUser, user.id == post.owner.id{
            return true
        } else {
            return false
        }
    }
}

#Preview {
    JoinRequestView(post: .constant(MockPost), isActive: .constant(true), refreshParticipants: {})
        .environmentObject(PostsViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(NavigationManager())
        .environmentObject(ActivityViewModel())
        .environmentObject(LocationManager())
        .environmentObject(WebSocketManager())


}

