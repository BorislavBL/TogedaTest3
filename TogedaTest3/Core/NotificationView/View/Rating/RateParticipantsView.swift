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
    
    @State var isLoading = false
    
    var post: Components.Schemas.PostResponseDto
    var rating: Components.Schemas.RatingDto
    @State var showUserLike = false
    @State var showUserReport = false
    @State var selectedExtendedUser: Components.Schemas.ExtendedMiniUser?
    @State var Init: Bool = true
    @EnvironmentObject var navManager: NavigationManager
    
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
                                NavigationLink(value: SelectionPath.profile(user.user)){
                                    HStack{
                                        KFImage(URL(string: user.user.profilePhotos[0]))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: size.dimension, height: size.dimension)
                                            .clipShape(Circle())
                                        
                                        VStack(alignment: .leading){
                                            Text("\(user.user.firstName) \(user.user.lastName)")
                                                .fontWeight(.semibold)
                                            if user._type == .CO_HOST || user._type == .HOST {
                                                Text(user._type.rawValue.capitalized)
                                                    .foregroundColor(.gray)
                                                    .fontWeight(.semibold)
                                                    .font(.footnote)
                                            }
                                            
                                        }
                                    }
                                    
                                }
                                Spacer()
                                
                                Button{
                                    showUserLike = true
                                    selectedExtendedUser = user
                                } label: {
                                    Image(systemName: "hand.thumbsup")
                                        .foregroundStyle(.green)
                                }
                                
                                Menu{
                                    Button("Report"){
                                        showUserReport = true
                                        selectedExtendedUser = user
                                    }
                                    if (post.currentUserRole == .CO_HOST || post.currentUserRole == .HOST) && (user._type != .HOST){
                                        Button("The user did not show"){
                                            
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
                    
                    if isLoading{
                        ProgressView()
                    }
                    
                    Rectangle()
                        .frame(width: 0, height: 0)
                        .onAppear {
                            if !eventVM.listLastPage {
                                isLoading = true
                                
                                Task{
                                    try await eventVM.fetchUserList(id: post.id)
                                    isLoading = false
                                    
                                }
                            }
                        }
                }
                .padding(.horizontal)
                
            }
            VStack(){
                Divider()
                
                Button {
                    if post.currentUserRole == .NORMAL{
                        Task{
                            if try await APIClient.shared.giveRatingToEvent(postId: post.id, ratingBody: rating) != nil {
                                DispatchQueue.main.async {
                                    self.navManager.selectionPath = []
                                }
                            }
                        }
                    } else {
                        navManager.selectionPath = []
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
        .sheet(isPresented: $showUserLike, content: {
            RateParticipantSheet(post: post, selectedExtendedUser: selectedExtendedUser, eventVM: eventVM, showUserLike: $showUserLike)
        })
        .sheet(isPresented: $showUserReport, content: {
            if let user = selectedExtendedUser {
                ReportUserView(user: user.user)
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
}

#Preview {
    RateParticipantsView(post: MockPost, rating: .init(value: 1.0, comment: "A taka"))
        .environmentObject(NavigationManager())
        .environmentObject(UserViewModel())
}

struct RateParticipantSheet: View {
    var post: Components.Schemas.PostResponseDto
    @State var description: String = ""
    var selectedExtendedUser: Components.Schemas.ExtendedMiniUser?
    @ObservedObject var eventVM: EventViewModel
    @Binding var showUserLike: Bool
    
    var body: some View {
        VStack{
            if let user = selectedExtendedUser {
                Text("You gave \(user.user.firstName) a like!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                VStack(alignment: .leading){
                    Text("Tell us what you liked about this person?")
                        .font(.body)
                        .fontWeight(.bold)
                    
                    TextField("(Optional)", text: $description, axis: .vertical)
                        .lineLimit(10, reservesSpace: true)
                        .padding()
                        .background{Color("main-secondary-color")}
                        .cornerRadius(10)
                    
                }
                .padding()
                .frame(minWidth: UIScreen.main.bounds.width, alignment: .leading)
                
                Spacer()
                
                Button{
                    Task{
                        if try await APIClient.shared.giveRatingToParticipant(postId: post.id, userId: user.user.id, ratingBody: .init(liked: true, comment: description)) != nil {
                            DispatchQueue.main.async {
                                if let index = eventVM.participantsList.firstIndex(where: { $0.user.id == user.user.id }) {
                                    eventVM.participantsList.remove(at: index)
                                    showUserLike = false
                                }
                            }
                        } else {
                            print("No no no")
                        }
                    }
                } label: {
                    HStack(spacing:2){
                        
                        Text("Send")
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
    }
}
