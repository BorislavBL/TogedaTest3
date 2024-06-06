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
    @State private var showJoinRequest: Bool = false
    
    let club = MockClub
    
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
                        
                        
                        if post.club != nil {
                            NavigationLink(value: SelectionPath.club(club)){
                                HStack(alignment: .center, spacing: 10) {
                                    KFImage(URL(string:club.images[0]))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(club.title)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        Text("Club Event")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .fontWeight(.bold)
                                    }
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .normalTagRectangleStyle()
                            }
                        }
                        
                        Group{
                            
                            HStack(alignment: .center, spacing: 10) {
                                Image(systemName: "calendar")
                                    .imageScale(.large)
                                if let from = post.fromDate {
                                    VStack(alignment: .leading, spacing: 5) {
                                        
                                        if let to = post.toDate{
                                            Text("\(separateDateAndTime(from: from).date) - \(separateDateAndTime(from: to).date)")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            Text("\(separateDateAndTime(from: from).time) - \(separateDateAndTime(from: to).time)")
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                                .fontWeight(.bold)
                                        } else {
                                            Text("\(separateDateAndTime(from: from).date)")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            Text(separateDateAndTime(from: from).time)
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                                .fontWeight(.bold)
                                        }
                                        
                                    }
                                } else {
                                    VStack(alignment: .leading, spacing: 5) {
                                        
                                        Text("Any Day")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        Text("There is no fixed Date&Time.")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                            
                            HStack(alignment: .center, spacing: 10) {
                                Image(systemName: "mappin.circle")
                                    .imageScale(.large)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    
                                    
                                    Text(locationCityAndCountry1(post.location))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    if !post.askToJoin || post.currentUserStatus == .PARTICIPATING {
                                        if let address = post.location.address {
                                            Text(address)
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                                .fontWeight(.bold)
                                        } else {
                                            Text(post.location.name)
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                                .fontWeight(.bold)
                                        }
                                    } else {
                                        Text("The exact location will be revealed upon joining.")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .fontWeight(.bold)
                                    }
                                    
                                }
                            }
                            
                            NavigationLink(value: SelectionPath.usersList(post: post)){
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "person.2")
                                        .imageScale(.large)
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        if let maxPeople = post.maximumPeople {
                                            Text("Participants \(post.participantsCount)/\(maxPeople)")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        } else {
                                            Text("Participants \(post.participantsCount)")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                        
                                        
                                        if eventVM.participantsList.count > 0 {
                                            ZStack{
                                                ForEach(0..<eventVM.participantsList.count, id: \.self){ number in
                                                    
                                                    if number < 4 {
                                                        KFImage(URL(string:eventVM.participantsList[number].user.profilePhotos[0]))
                                                            .resizable()
                                                            .background(.gray)
                                                            .scaledToFill()
                                                            .frame(width: 40, height: 40)
                                                            .clipped()
                                                            .cornerRadius(100)
                                                            .overlay(
                                                                Circle()
                                                                    .stroke(Color("main-secondary-color"), lineWidth: 2)
                                                            )
                                                            .offset(x:CGFloat(20 * number))
                                                    }
                                                    
                                                }
                                                
                                                if eventVM.participantsList.count > 4 {
                                                    
                                                    Circle()
                                                        .fill(.gray)
                                                        .frame(width: 40, height: 40)
                                                        .overlay(
                                                            ZStack(alignment:.center){
                                                                Text("+\(eventVM.participantsList.count - 3)")
                                                                    .font(.caption2)
                                                                    .fontWeight(.semibold)
                                                                    .foregroundColor(.white)
                                                                Circle()
                                                                    .stroke(Color("main-secondary-color"), lineWidth: 2)
                                                            }
                                                        )
                                                        .offset(x:CGFloat(20 * 4))
                                                }
                                            }
                                            
                                            
                                        }
                                    }
                                }
                            }
                            
                            HStack(alignment: .center, spacing: 10) {
                                Image(systemName: "globe.europe.africa.fill")
                                    .imageScale(.large)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(post.accessibility.rawValue.capitalized)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Text("Everyone can join the event")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .fontWeight(.bold)
                                }
                            }
                            
                            HStack(alignment: .center, spacing: 10) {
                                Image(systemName: "wallet.pass")
                                //                                    .resizable()
                                //                                    .scaledToFit()
                                //                                    .frame(width: 25, height: 25)
                                    .imageScale(.large)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    
                                    if post.payment <= 0 {
                                        Text("Free")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        Text("No payment required")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .fontWeight(.bold)
                                    } else {
                                        Text("Paid")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        Text("$ \(String(format: "%.2f", post.payment)) per person")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                            
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .normalTagRectangleStyle()
                        
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
                            
                            Text(locationAddress1(post.location))
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
            Task{       
                do {
                    eventVM.participantsList = []
                    eventVM.participantsPage = 0
                    try await eventVM.fetchUserList(id: post.id)
                } catch {
                    print("Failed to fetch user list: \(error)")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showPostOptions, content: {
            List {
                Button("Save") {
                    postsVM.selectedOption = "Save"
                }
                
                ShareLink(item: URL(string: "https://www.youtube.com/")!) {
                    Text("Share via")
                }
                
                if isOwner {

                } else {
                    Button("Report") {
                        postsVM.selectedOption = "Report"
                    }
                }
            }
            .scrollDisabled(true)
            .presentationDetents([.fraction(0.25)])
            .presentationDragIndicator(.visible)
        })
        .sheet(isPresented: $showJoinRequest){
            JoinRequestView(post: $post)
        }
        .sheet(isPresented: $showSharePostSheet) {
            ShareView()
                .presentationDetents([.fraction(0.8), .fraction(1) ])
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
                //NavigationLink(value: SelectionPath.editEvent(post: post))
                Button{
                    isEditing = true
                } label:{
                    Image(systemName: "square.and.pencil")
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
                if post.currentUserStatus == .PARTICIPATING {
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
                        } else if post.status == .NOT_STARTED {
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
                        } else if post.status == .NOT_STARTED {
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
                        }

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
            userViewModel.savePost(postId: post.id)
        } label: {
            Image(systemName: userViewModel.user.details.savedPostIds.contains(post.id) ? "bookmark.fill" : "bookmark")
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
    
}



struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(post: MockPost)
            .environmentObject(PostsViewModel())
            .environmentObject(UserViewModel())
    }
}
