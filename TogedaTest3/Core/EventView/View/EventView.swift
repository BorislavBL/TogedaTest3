//
//  EventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import MapKit
import WrappingHStack

struct EventView: View {
    @EnvironmentObject var viewModel: PostsViewModel
    var postID: String
    var post: Post? {
        return viewModel.posts.first(where: {$0.id == postID})
    }
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var peopleIn: Int = 0
    @State private var showSharePostSheet: Bool = false
    
    @State private var address: String?
    @State var showPostOptions = false
    @State private var showJoinRequest: Bool = false
    let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
    
    let club = Club.MOCK_CLUBS[0]
    
    var body: some View {
        if let post = post {
            ZStack(alignment: .bottom) {
                ScrollView{
                    LazyVStack(alignment: .leading, spacing: 15) {
                        
                        TabView {
                            ForEach(post.imageUrl, id: \.self) { image in
                                Image(image)
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                                
                            }
                            
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .frame(height: 500)
                        
                        VStack(alignment: .leading){
                            Text(post.title)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            if let user = post.user {
                                NavigationLink(destination: UserProfileView(miniUser: user)){
                                    HStack(alignment: .center, spacing: 10) {
                                        
                                        
                                        if let image = post.user?.profileImageUrl {
                                            Image(image[0])
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 60, height: 60)
                                                .clipped()
                                                .cornerRadius(15)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 5) {
                                            
                                            if let user = post.user {
                                                
                                                Text(user.fullName)
                                                    .font(.body)
                                                    .fontWeight(.semibold)
                                                
                                                Text(user.occupation)
                                                    .font(.footnote)
                                                    .foregroundColor(.gray)
                                                    .fontWeight(.bold)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if post.inClubID != nil {
                                NavigationLink(destination: GroupView(clubID: club.id)){
                                    HStack(alignment: .center, spacing: 10) {
                                        Image(club.imagesUrl[0])
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
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("\(separateDateAndTime(from: post.date).weekday), \(separateDateAndTime(from: post.date).date)")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        Text(separateDateAndTime(from: post.date).time)
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .fontWeight(.bold)
                                    }
                                }
                                
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "mappin.circle")
                                        .imageScale(.large)
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        
 
                                            Text(locationCityAndCountry(post.location))
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                        if post.peopleIn.contains(userViewModel.user.id) || !post.askToJoin{
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
                                
                                NavigationLink(destination: UsersListView(users: post.participants, post: post)){
                                    HStack(alignment: .center, spacing: 10) {
                                        Image(systemName: "person.3")
                                            .imageScale(.large)
                                        
                                        VStack(alignment: .leading, spacing: 5) {
                                            if let maxPeople = post.maximumPeople {
                                                Text("Participants \(post.peopleIn.count)/\(maxPeople)")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                            } else {
                                                Text("Participants \(post.peopleIn.count)")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                            }
                                            
                                            
                                            if post.participants.count > 0 {
                                                ZStack{
                                                    ForEach(0..<post.participants.count, id: \.self){ number in
                                                        
                                                        if number < 4{
                                                            Image(post.participants[number].profileImageUrl[0])
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 40, height: 40)
                                                                .clipped()
                                                                .cornerRadius(100)
                                                                .overlay(
                                                                    Circle()
                                                                        .stroke(Color("secondaryColor"), lineWidth: 2)
                                                                )
                                                                .offset(x:CGFloat(20 * number))
                                                        }
                                                        
                                                    }
                                                    
                                                    if post.peopleIn.count > 4 {
                                                        
                                                        Circle()
                                                            .fill(.gray)
                                                            .frame(width: 40, height: 40)
                                                            .overlay(
                                                                ZStack(alignment:.center){
                                                                    Text("+\(post.peopleIn.count - 3)")
                                                                        .font(.caption2)
                                                                        .fontWeight(.semibold)
                                                                        .foregroundColor(.white)
                                                                    Circle()
                                                                        .stroke(Color("secondaryColor"), lineWidth: 2)
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
                                        Text(post.accessability.value.capitalized)
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
                            
                            
                            Text("Description")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.vertical, 8)
                            
                            ExpandableText(post.description, lineLimit: 4)
                                .lineSpacing(8.0)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                                .padding(.bottom, 8)
                            
                            Text("Location")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.vertical, 8)
                            
                            if post.peopleIn.contains(userViewModel.user.id) || !post.askToJoin{
                                
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
                .background(Color("testColor"))
                .scrollIndicators(.hidden)
                .edgesIgnoringSafeArea(.top)
                
                VStack {
                    navbar()
                    
                    Spacer()
                    
                    bottomBar()

                }
            }
//            .background{
//                SwipeBackGesture{
//                    self.dismiss()
//                }
//            }
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showPostOptions, content: {
                List {
                    Button("Save") {
                        viewModel.selectedOption = "Save"
                    }
                    
                    ShareLink(item: URL(string: "https://www.youtube.com/")!) {
                        Text("Share via")
                    }
                    
                    Button("Report") {
                        viewModel.selectedOption = "Report"
                    }
                    
                    
                    if let user = post.user, user.id == userId {
                        Button("Delete") {
                            viewModel.selectedOption = "Delete"
                        }
                    }
                }
                .presentationDetents([.fraction(0.25)])
                .presentationDragIndicator(.visible)
            })
            .sheet(isPresented: $showJoinRequest){
                JoinRequestView()
            }
            .sheet(isPresented: $showSharePostSheet) {
                ShareView()
                    .presentationDetents([.fraction(0.8), .fraction(1) ])
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                self.peopleIn = post.peopleIn.count
            }
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
            
            if let post = post, let user = post.user, user.id == userId{
                NavigationLink(destination: EditEventView(post: post)) {
                    Image(systemName: "square.and.pencil")
                        .frame(width: 35, height: 35)
                        .background(.bar)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                }
            }
            
            Button{
                showPostOptions = true
                viewModel.clickedPostID = postID
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
                if let post = post, post.date <= Date() {
                    if let user = post.user, user.id == userId {
                        Button {
                            
                        } label: {
                            Text("Stop the Event")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .cornerRadius(10)
                        }
                    } else {
                        Button {
                            //                                    viewModel.likePost(postID: post.id, userID: userViewModel.user.id, user: userViewModel.user)
                            viewModel.clickedPostID = post.id
                            showJoinRequest = true
                        } label: {
                            HStack(spacing:2){
                                if post.peopleIn.contains(userViewModel.user.id) {
                                    Image(systemName:"checkmark")
                                    Text("Joined")
                                        .fontWeight(.semibold)
                                } else {
                                    Text("Join")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                        }
                    }
                    
                    Button {
                        viewModel.clickedPostID = post.id
                        showSharePostSheet = true
                    } label: {
                        Image(systemName:"paperplane")
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .frame(width: 60, height: 60)
                            .background(Color("secondaryColor"))
                            .cornerRadius(10)
                    }
                    
                    Button {
                        userViewModel.savePost(postId: post.id)
                    } label: {
                        Image(systemName: userViewModel.user.savedPosts.contains(post.id) ? "bookmark.fill" : "bookmark")
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .frame(width: 60, height: 60)
                            .background(Color("secondaryColor"))
                            .cornerRadius(10)
                    }
                } else {
                    if let user = post?.user, user.id == userId {
                        Button {
                            
                        } label: {
                            HStack(spacing:2){
                                Text("End the event")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                        }
                    } else {
                        Button {
                            
                        } label: {
                            HStack(spacing:2){
                                Text("Ongoing Event")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
        }
        .background(.bar)
    }
    
}



struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(postID: Post.MOCK_POSTS[0].id)
            .environmentObject(PostsViewModel())
            .environmentObject(UserViewModel())
    }
}
