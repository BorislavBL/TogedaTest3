//
//  RateParticipantsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.06.24.
//

import SwiftUI
import Kingfisher

struct RateParticipantsView: View {
    @Environment(\.dismiss) private var dismiss
    let size: ImageSize = .medium
    @StateObject var eventVM = EventViewModel()
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var wsManager: WebSocketManager
    
    @State var isLoading = false
    
    var post: Components.Schemas.PostResponseDto
    var rating: Components.Schemas.RatingDto

    @State var Init: Bool = true
    @EnvironmentObject var navManager: NavigationManager
    @ObservedObject var vm: RatingViewModel
    
    var body: some View {
        VStack{
            ScrollView{
                Text("What do you think of the people from this event?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                LazyVStack(alignment:.leading){
                    ForEach(eventVM.participantsList, id:\.user.id) { user in
                        if let currentUser = userVM.currentUser, currentUser.id == user.user.id{
                            EmptyView()
                        } else {
                            HStack{
//                                NavigationLink(value: SelectionPath.profile(user.user)){
                                    HStack{
                                        KFImage(URL(string: user.user.profilePhotos[0]))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: size.dimension, height: size.dimension)
                                            .clipShape(Circle())
                                        
                                        VStack(alignment: .leading){
                                            HStack(spacing: 5){
                                                Text("\(user.user.firstName) \(user.user.lastName)")
                                                
                                                if user.user.userRole == .AMBASSADOR {
                                                    AmbassadorSealMini()
                                                } else if user.user.userRole == .PARTNER {
                                                    PartnerSealMini()
                                                }
                                            }
                                                .fontWeight(.semibold)
                                            if user._type == .CO_HOST || user._type == .HOST {
                                                Text(user._type.rawValue.capitalized)
                                                    .foregroundColor(.gray)
                                                    .fontWeight(.semibold)
                                                    .font(.footnote)
                                            }
                                            
                                        }
                                    }
                                    
//                                }
                                Spacer()
                                
                                if vm.ratePostParticipants.contains(where: {$0.userId == user.user.id}){
                                    Image(systemName: "hand.thumbsup.fill")
                                        .foregroundStyle(.green)
                                } else {
                                    Button{
                                        vm.selectedExtendedUser = user
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            vm.showUserLike = true
                                        }
                                        
                                    } label: {
                                        Image(systemName: "hand.thumbsup")
                                            .foregroundStyle(.green)
                                    }
                                }
                                
                                Menu{
                                    Button("Report"){
                                        vm.selectedExtendedUser = user
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            vm.showUserReport = true
                                        }
                                        
                                    }
                                    if (post.currentUserRole == .HOST) && (user._type != .HOST){
                                        Button("The user did not show"){
                                            userDidNotShow(user: user.user)
                                        }
                                    }
                                }label:{
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundStyle(.red)
                                }
                                
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    
                    ListLoadingButton(isLoading: $isLoading, isLastPage: eventVM.listLastPage) {
                        Task{
                            try await eventVM.fetchUserList(id: post.id)
                            isLoading = false
                        }
                    }
                }
                .padding(.horizontal)
                
            }
            VStack(){
                Divider()
                
                Button {
                    Task {
                        if post.currentUserRole == .NORMAL {
                            // Step 1: Submit all likes
                            await vm.submitAllLikes()
                            print("here1")
                            // Step 2: Remove rating notifications after all likes are submitted
                            do {
                                if try await APIClient.shared.giveRatingToEvent(postId: post.id, ratingBody: rating) != nil {
                                    print("here2")

                                    if let removed = try await APIClient.shared.removeRatingNotifications(postId: post.id), removed {
                                        print("here3")

                                        DispatchQueue.main.async {
                                            wsManager.notificationsList.removeAll { not in
                                                return not.alertBodyReviewEndedPost?.post.id == post.id
                                            }
                                            self.vm.openReviewSheet = false
                                        }
                                    }
                                }
                            } catch {
                                print("Failed to submit rating or remove notifications:", error)
                            }
                        } else {
                            await vm.submitAllLikes()
                            // For other roles, skip submitting likes and directly remove notifications
                            do {
                                if let removed = try await APIClient.shared.removeRatingNotifications(postId: post.id), removed {
                                    DispatchQueue.main.async {
                                        wsManager.notificationsList.removeAll { not in
                                            return not.alertBodyReviewEndedPost?.post.id == post.id
                                        }
                                        self.vm.openReviewSheet = false
                                    }
                                }
                            } catch {
                                print("Failed to remove notifications:", error)
                            }
                        }
                    }
                } label: {
                    HStack(spacing:2){
                        
                        Text("Finish")
                            .fontWeight(.semibold)
                        
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .cornerRadius(10)
                }
                .padding()
            }
            .background(.bar)
        }
        .swipeBack()
        .sheet(isPresented: $vm.showUserLike, content: {
            RateParticipantSheet(post: post, selectedExtendedUser: vm.selectedExtendedUser, eventVM: eventVM, showUserLike: $vm.showUserLike, vm: vm)
        })
        .sheet(isPresented: $vm.showUserReport, content: {
            if let user = vm.selectedExtendedUser {
                ReportUserView(user: user.user, isActive: $vm.showUserReport)
            }
        })
        .onAppear(){
            Task{
                do{
                    if Init {
                        try await eventVM.fetchUserList(id: post.id)
                        Init = false
                    }
                } catch {
                    print("User list error:", error.localizedDescription)
                }
            }
        }
        .navigationTitle("Participants")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
        
    }
    
    func userDidNotShow(user: Components.Schemas.MiniUser) {
            let report: Components.Schemas.ReportDto = .init(
                reportType: .NOT_SHOWN,
                description: "The user did not show to the event.",
                reportedUser: user.id,
                reportedPost: nil,
                reportedClub: nil
            )
            
            Task{
                if let _ = try await APIClient.shared.report(body: report) {

                }
            }
        
    }
    
}

#Preview {
    RateParticipantsView(post: MockPost, rating: .init(value: 1.0, comment: "A taka"), vm: RatingViewModel())
        .environmentObject(NavigationManager())
        .environmentObject(WebSocketManager())
        .environmentObject(UserViewModel())
}

struct RateParticipantSheet: View {
    var post: Components.Schemas.PostResponseDto
    @State var description: String = ""
    var selectedExtendedUser: Components.Schemas.ExtendedMiniUser?
    @ObservedObject var eventVM: EventViewModel
    @Binding var showUserLike: Bool
    @ObservedObject var vm: RatingViewModel
    
    var body: some View {
        VStack{
            if let user = selectedExtendedUser {
                VStack(alignment: .center, spacing: 10) {
                    KFImage(URL(string: user.user.profilePhotos[0]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                    
                    Text("\(user.user.firstName) \(user.user.lastName)")
                        .fontWeight(.semibold)
                        .font(.title3)
                }
                
                
                VStack(alignment: .leading){
                    TextField("Tell us what you liked about \(user.user.firstName)? (Optional)", text: $description, axis: .vertical)
                        .lineLimit(10, reservesSpace: true)
                        .padding()
                        .background{Color("main-secondary-color")}
                        .cornerRadius(10)
                    
                }
                .padding()
                .frame(minWidth: UIScreen.main.bounds.width, alignment: .leading)
                
                Spacer()
                
                Button{
//                    Task{
//                        if try await APIClient.shared.giveRatingToParticipant(postId: post.id, userId: user.user.id, ratingBody: .init(liked: true, comment: description)) != nil {
//                            DispatchQueue.main.async {
//                                if let index = eventVM.participantsList.firstIndex(where: { $0.user.id == user.user.id }) {
//                                    eventVM.participantsList.remove(at: index)
//                                    showUserLike = false
//                                }
//                            }
//                        } else {
//                            print("No no no")
//                        }
//                    }
                    vm.ratePostParticipants.append(.init(postId: post.id, userId: user.user.id, rating: .init(liked: true, comment: description)))
                    showUserLike = false
                } label: {
                    HStack(spacing:2){
                        
                        Text("Give \(user.user.firstName) a Like")
                            .fontWeight(.semibold)
                        
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .cornerRadius(10)
                }
                .padding()
                
            }
        }
        .padding(.top, 26)
    }
}
