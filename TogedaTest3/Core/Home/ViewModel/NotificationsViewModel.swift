////
////  NotificationsViewModel.swift
////  TogedaTest3
////
////  Created by Borislav Lorinkov on 24.06.24.
////
//
//import Foundation
//
//class NotificationsViewModel: ObservableObject {
//    @Published var notificationsList: [Components.Schemas.NotificationDto] = []
//    @Published var page: Int32 = 0
//    @Published var size: Int32 = 15
//    @Published var count: Int64 = 0
//    @Published var lastPage: Bool = true
//    @Published var notificationPoolingActivated = true
//    
//    func fetchInitialNotification(completion: @escaping (Bool) -> Void) async throws {
//        do {
//            if let response = try await APIClient.shared.notificationsList(page: page, size: size){
//                DispatchQueue.main.async {
//                    self.notificationsList += response.data
//                    self.page += 1
//                    self.count = response.listCount
//                    self.lastPage = response.lastPage
//                    
//                    completion(true)
//                }
//            }
//        } catch {
//            print("error:", error)
//            completion(false)
//        }
//    }
//
////    func fetchPollNotification() async throws {
////        while notificationPoolingActivated {
////            do {
////                if notificationsList.count > 0 {
////                    print("start Pool")
////                    try await APIClient.shared.notificationsPoll(lastTimestamp: notificationsList[0].createdDate, lastId: notificationsList[0].id){ response, error in
////                        if let response = response {
////                            DispatchQueue.main.async { [weak self] in
////                                print("Notification responsw:", response)
////                                if response.count != 0 {
////                                    self?.notificationsList.insert(contentsOf: response, at: 0)
////                                }
////                                print("end Pool")
////                            }
////                        } else if error != nil {
////                            Task{
////                                try await Task.sleep(nanoseconds: 60_000_000_000) // Sleep for 60 second
////                            }
////                        }
////                    }
////                } else {
////                    try await APIClient.shared.notificationsPoll(lastTimestamp: Date(), lastId: 0){ response, error in
////                        if let response = response {
////                            DispatchQueue.main.async { [weak self] in
////                                print("Notification responsw:", response)
////                                if response.count != 0 {
////                                    self?.notificationsList.insert(contentsOf: response, at: 0)
////                                }
////                            }
////                        }
////                        else if error != nil {
////                            Task{
////                                try await Task.sleep(nanoseconds: 60_000_000_000) // Sleep for 60 second
////                            }
////                        }
////                    }
////                }
////                
////                try await Task.sleep(nanoseconds: 1_000_000_000) // Sleep for 1 second
////                
////            } catch {
////                print("error:", error)
////            }
////        }
////    }
//}
//
//extension NotificationsViewModel {
//    func addNotification(newNotification: Components.Schemas.NotificationDto) {
//        if let not = newNotification.alertBodyAcceptedJoinRequest{
//            switch not.forType {
//            case .CLUB:
//                if let club = not.club{
//                    notificationsList.insert(newNotification, at: 0)
//                }
//            case .POST:
//                if let post = not.post{
//                    notificationsList.insert(newNotification, at: 0)
//                }
//            case .none: break
//                
//            }
//        } else if let not = newNotification.alertBodyReceivedJoinRequest{
//            switch not.forType {
//            case .POST:
//                if let post = not.post{
//                    notificationsList.removeAll { notification in
//                        if let not = notification.alertBodyReceivedJoinRequest, let newPost = not.post, newPost.id == post.id {
//                            return true
//                        } else {
//                            return false
//                        }
//                    }
//                    notificationsList.insert(newNotification, at: 0)
//                }
//            case .CLUB:
//                if let club = not.club{
//                    notificationsList.removeAll { notification in
//                        if let not = notification.alertBodyReceivedJoinRequest, let newClub = not.club, newClub.id == club.id {
//                            return true
//                        } else {
//                            return false
//                        }
//                    }
//                    notificationsList.insert(newNotification, at: 0)
//                }
//            case .none: break
//                
//            }
//        } else if let not = newNotification.alertBodyFriendRequestReceived{
//            notificationsList.removeAll { $0.alertBodyFriendRequestReceived != nil }
//            notificationsList.insert(newNotification, at: 0)
//        } else if let not = newNotification.alertBodyReviewEndedPost {
//            notificationsList.insert(newNotification, at: 0)
//        }
//    }
//}
