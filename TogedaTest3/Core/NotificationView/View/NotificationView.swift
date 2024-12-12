//
//  NotificationView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.11.23.
//

import SwiftUI

struct NotificationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: WebSocketManager
    @EnvironmentObject var navManager: NavigationManager
    @State var isLoading = false
    @StateObject var ratingVM = RatingViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false){
            LazyVStack(spacing: 16){
                if vm.notificationsList.count > 0 {
                    ForEach(vm.notificationsList, id: \.id) { notification in
                        // Handle different cases of alertBody
                        if let not = notification.alertBodyAcceptedJoinRequest{
                            switch not.forType {
                            case .CLUB:
                                if let club = not.club{
                                    GroupAcceptanceView(club: club, createDate: notification.createdDate, alertBody: not, selectionPath: $navManager.selectionPath)
                                }
                            case .POST:
                                if let post = not.post{
                                    EventAcceptance(post: post, createDate: notification.createdDate, alertBody: not, selectionPath: $navManager.selectionPath)
                                }
                            case .none:
                                EmptyView()
                            }
                        } else if let not = notification.alertBodyReceivedJoinRequest{
                            switch not.forType {
                            case .POST:
                                if let post = not.post{
                                    EventRequestPage(post: post, createDate: notification.createdDate, alertBody: not, selectionPath: $navManager.selectionPath)
                                }
                            case .CLUB:
                                if let club = not.club{
                                    GroupRequestPage(club: club, createDate: notification.createdDate, alertBody: not, selectionPath: $navManager.selectionPath)
                                }
                            case .none:
                                EmptyView()
                            }
                        } else if let not = notification.alertBodyFriendRequestReceived{
                            FriendRequestView(user: not, createDate: notification.createdDate)
                        } else if let not = notification.alertBodyReviewEndedPost {
                            ParticipantsEventReview(alertBody: not, createDate: notification.createdDate, ratingVM: ratingVM)
                        } else if let not = notification.alertBodyPostHasStarted {
                            EventHasStartedView(createDate: notification.createdDate, alertBody: not, selectionPath: $navManager.selectionPath)
                        } else if let not = notification.alertBodyFriendRequestAccepted {
                            AcceptedFriendRequestView(user: not, createDate: notification.createdDate)
                        } else if let not = notification.alertBodyUserAddedToParticipants {
                            switch not.forType {
                            case .POST:
                                if let post = not.post{
                                    UserJoinsEventPage(post: post, createDate: notification.createdDate, alertBody: not, selectionPath: $navManager.selectionPath)
                                }
                            case .CLUB:
                                if let club = not.club{
                                    UserJoinsClubPage(club: club, createDate: notification.createdDate, alertBody: not, selectionPath: $navManager.selectionPath)
                                }
                            case .none:
                                EmptyView()
                            }
                        }
                    }
                } else if vm.loadingState == .noResults{
                    VStack(spacing: 15){
                        Text("🔔")
                            .font(.custom("image", fixedSize: 120))
                        
                        Text("You're all caught up! No notifications here… for now. Join clubs, attend events, and connect with friends to stay in the loop!")
                            .font(.body)
                            .foregroundStyle(.gray)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding(.bottom)
                        
                    }
                    .padding(.all)
                    .frame(maxHeight: .infinity, alignment: .center)
                }
//                FriendRequestPage()
//                FriendRequestView()
//                AddedMemoryView()
//                SystemNotificationView()
                
                if isLoading {
                    ProgressView() // Show spinner while loading
                }
                
                Rectangle()
                    .frame(width: 0, height: 0)
                    .onAppear {
                        if !vm.lastPage{
                            isLoading = true
                            Task{
                                try await vm.fetchInitialNotification(){ success in
                                    isLoading = false
                                }
                            }
                        }
                    }
                
            }
            .padding()
        }
        .refreshable {
            vm.notificationsList = []
            vm.page = 0
            vm.count = 0
            vm.lastPage = true
            vm.loadingState = .loading
            Task{
                try await vm.fetchInitialNotification(){ success in
                    isLoading = false
                }
            }
        }
        .onChange(of:ratingVM.openReviewSheet) { oldValue, newValue in
            if !newValue {
                ratingVM.resetAll()
            }
        }
        .fullScreenCover(isPresented: $ratingVM.openReviewSheet, content: {
            if let not = ratingVM.reviewAlertBody {
                NavigationStack{
                    VStack {
                        if not.post.currentUserRole == .NORMAL, let post = ratingVM.post {
                            EventReviewView(post: post, vm: ratingVM)
                        } else if let post = ratingVM.post, post.participantsCount > 1 {
                            RateParticipantsView(post: post, rating: .init(value: 5.0, comment: nil), vm: ratingVM)
                        } else {
                            VStack{
                                HStack{
                                    Spacer()
                                    Button(action: {ratingVM.openReviewSheet = false}) {
                                        Image(systemName: "xmark")
                                            .imageScale(.medium)
                                            .padding(.all, 8)
                                            .background(Color("main-secondary-color"))
                                            .clipShape(Circle())
                                    }
                                }
                                .padding()
                                Spacer()
                                Text("There are no participants for rating...")
                                    .onAppear(){
                                        ratingVM.openReviewSheet = false
                                    }
                                Spacer()
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarBackButtonHidden(true)
                }
//                .navigationBarItems(trailing:Button(action: {ratingVM.openReviewSheet = false}) {
//                    Image(systemName: "xmark")
//                        .imageScale(.medium)
//                        .padding(.all, 8)
//                        .background(Color("main-secondary-color"))
//                        .clipShape(Circle())
//                }
//                )
            } else {
                VStack{
                    HStack{
                        Spacer()
                        Button(action: {ratingVM.openReviewSheet = false}) {
                            Image(systemName: "xmark")
                                .imageScale(.medium)
                                .padding(.all, 8)
                                .background(Color("main-secondary-color"))
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                    Spacer()
                    Text("Something went wrong...")
                        .onAppear(){
                            ratingVM.openReviewSheet = false
                        }
                    Spacer()
                }
            }
        })
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .navButton3()
        }
        )
        .swipeBack()
        .onAppear(){
            if navManager.activateReviewSheet {
                ratingVM.openReviewSheet = true
                navManager.activateReviewSheet = false
            }
        }
        
    }
}


#Preview {
    NotificationView()
        .environmentObject(WebSocketManager())
        .environmentObject(NavigationManager())
}
