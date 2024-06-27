//
//  EventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import MapKit
import WrappingHStack
import Kingfisher

struct EventView: View {
    
    @StateObject var eventVM = EventViewModel()
    
    @EnvironmentObject var postsVM: PostsViewModel
    @State var post: Components.Schemas.PostResponseDto
    @State var isEditing = false
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showSharePostSheet: Bool = false
    @State var showPostOptions = false
    @State var showReportEvent = false
    @State private var showJoinRequest: Bool = false
    
    @State var club: Components.Schemas.ClubDto?
    
    @State private var Init = true
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            ScrollView{
                LazyVStack(alignment: .leading, spacing: 15) {
                    
                    TabView {
                        ForEach(post.images, id: \.self) { image in
                            KFImage(URL(string: image))
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width)
                                .clipped()
                            
                        }
                        
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: UIScreen.main.bounds.width * 1.5)
                    
                    VStack(alignment: .leading){
                        Text(post.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        
                        NavigationLink(value: SelectionPath.profile(post.owner)){
                            HStack(alignment: .center, spacing: 10) {
                                                                
                                KFImage(URL(string: post.owner.profilePhotos[0]))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipped()
                                    .cornerRadius(15)
                                
                                
                                VStack(alignment: .leading, spacing: 5) {
                                                                        
                                    Text("\(post.owner.firstName) \(post.owner.lastName)")
                                        .font(.body)
                                        .fontWeight(.semibold)
                                    
                                    Text(post.owner.occupation)
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .fontWeight(.bold)
                                    
                                }
                            }
                        }
                        
                        AllEventTabsView(eventVM: eventVM, post: post, club: club)
                        
                        
                        if let description = post.description {
                            Text("Description")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.vertical, 8)
                            
                            ExpandableText(description, lineLimit: 4)
                                .lineSpacing(8.0)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                                .padding(.bottom, 8)
                        }
                        
                        
                        Text("Location")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.vertical, 8)
                        
                        if !post.askToJoin || post.currentUserStatus == .PARTICIPATING{
                            
                            Text(locationAddress(post.location))
                                .normalTagTextStyle()
                                .normalTagCapsuleStyle()
                            
                            MapSlot(name:post.title, latitude: post.location.latitude, longitude: post.location.longitude)
                            
                        } else {
                            Text("The location will be revealed upon joining.")
                                .lineSpacing(8.0)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                                .padding(.bottom, 8)
                        }
                        
                        Text("Interests")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.vertical, 8)
                        
                        WrappingHStack(alignment: .leading, horizontalSpacing: 5){
                            ForEach(post.interests, id:\.self){ interest in
                                Text("\(interest.icon) \(interest.name)")
                                    .normalTagTextStyle()
                                    .normalTagCapsuleStyle()
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                }
                .padding(.bottom, 100)
                .background(.bar)
            }
            .refreshable {
                Task{
                    do {

                        if let response = try await APIClient.shared.getEvent(postId: post.id) {
                            if let index = postsVM.feedPosts.firstIndex(where: { $0.id == post.id }) {
                                postsVM.feedPosts[index] = response
                                post = response
                            }
                        }

                        eventVM.participantsList = []
                        eventVM.participantsPage = 0
                        try await eventVM.fetchUserList(id: post.id)
                    } catch {
                        print("Failed to fetch user list: \(error)")
                    }
                }
            }
            .background(Color("testColor"))
            .scrollIndicators(.hidden)
            .edgesIgnoringSafeArea(.top)
            
            VStack {
                navbar()
                
                Spacer()
                
                bottomBar()
                
            }
        }
        .onAppear(){
            eventVM.participantsList = []
            eventVM.participantsPage = 0
            Task{
                await fetchAllOnAppear()
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showPostOptions, content: {
            List {
                
                ShareLink(item: URL(string: "https://www.youtube.com/")!) {
                    Text("Share via")
                }
                
                if isOwner {

                } else {
                    Button("Report") {
                        showPostOptions = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            showReportEvent = true
                        }
                    }
                }
            }
            .scrollDisabled(true)
            .presentationDetents([.fraction(0.25)])
            .presentationDragIndicator(.visible)
        })
        .sheet(isPresented: $showReportEvent, content: {
            ReportEventView(event: post)
        })
        .sheet(isPresented: $showJoinRequest){
            JoinRequestView(post: $post, isActive: $showJoinRequest, refreshParticipants: {
                Task{
                    do {
                        eventVM.participantsList = []
                        eventVM.participantsPage = 0
                        try await eventVM.fetchUserList(id: post.id)
                    } catch {
                        print("Failed to fetch user list: \(error)")
                    }
                }
            })
        }
        .sheet(isPresented: $showSharePostSheet) {
            ShareView()
                .presentationDetents([.fraction(0.8), .fraction(1)])
                .presentationDragIndicator(.visible)
        }
        
    }
    
    @ViewBuilder
    func navbar() -> some View {
        HStack(alignment: .center){
            Button(action: {dismiss()}) {
                Image(systemName: "chevron.left")
                    .frame(width: 35, height: 35)
                    .background(.bar)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            }
            Spacer()
            
            if isOwner {
                Button{
                    isEditing = true
                } label:{
                    Image(systemName: "pencil")
                        .frame(width: 35, height: 35)
                        .background(.bar)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                }
            }
            
            Button{
                showPostOptions = true
                postsVM.clickedPost = post
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .frame(width: 35, height: 35)
                    .background(.bar)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func bottomBar() -> some View {
        VStack{
            Divider()
            
            HStack{
                
                if isOwner {
                    if post.status == .HAS_STARTED {
                        Button {
                            showJoinRequest = true
                        } label: {
                            Text("Stop the Event")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .cornerRadius(10)
                        }
                    }
                    else if post.status == .NOT_STARTED {
                        if post.fromDate != nil {
                            Button {
                                showJoinRequest = true
                            } label: {
                                Text("End the Event")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                            }
                        } else {
                            Button {
                                showJoinRequest = true
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
                    }
                    else if post.status == .HAS_ENDED {
                        Text("Ended")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                    }
                    else {
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
                        Button {
                            showJoinRequest = true
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
                    else if post.status == .NOT_STARTED {
                        if post.currentUserStatus == .PARTICIPATING {
                            Button {
                                showJoinRequest = true
                            } label: {
                                Text("Leave")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                            }
                        } else if post.currentUserStatus == .IN_QUEUE {
                            Button {
                                showJoinRequest = true
                            } label: {
                                Text("Waiting")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                            }
                        } else {
                            Button {
                                showJoinRequest = true
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
                    else if post.status == .HAS_ENDED {
                        Text("Ended")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                    }
                    else {
                        Button {
                            showJoinRequest = true
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

                
                shareAndSave()
            }
            .padding(.horizontal)
            
        }
        .background(.bar)
        .navigationDestination(isPresented: $isEditing) {
            EditEventView(isActive: $isEditing, post: $post)
        }
    }
    
    @ViewBuilder
    func shareAndSave() -> some View {
        Button {
            postsVM.clickedPost = post
            showSharePostSheet = true
        } label: {
            Image(systemName:"paperplane")
                .resizable()
                .scaledToFit()
                .padding()
                .frame(width: 60, height: 60)
                .background(Color("main-secondary-color"))
                .cornerRadius(10)
        }
        
        Button {
            Task{
                if let saved = try await postsVM.saveEvent(postId: post.id) {
                    post.savedByCurrentUser = saved
                }
            }
        } label: {
            Image(systemName: post.savedByCurrentUser ? "bookmark.fill" : "bookmark")
                .resizable()
                .scaledToFit()
                .padding()
                .frame(width: 60, height: 60)
                .background(Color("main-secondary-color"))
                .cornerRadius(10)
        }
    }
    
    var isOwner: Bool {
        if let user = userViewModel.currentUser, user.id == post.owner.id{
            return true
        } else {
            return false
        }
    }
    
    func fetchAllOnAppear() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    if let clubId = await post.clubId, let response = try await APIClient.shared.getClub(clubID: clubId){
                        DispatchQueue.main.async {
                            self.club = response
                            
                            self.Init = false
                        }

                    }
                } catch {
                    print(error)
                }
            }
            
            group.addTask {
                do {
                    try await eventVM.fetchUserList(id: post.id)
                } catch {
                    print(error)
                }
            }
        }
    }
    
}



struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(post: MockPost)
            .environmentObject(PostsViewModel())
            .environmentObject(UserViewModel())
    }
}
