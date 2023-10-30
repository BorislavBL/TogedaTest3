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
    @ObservedObject var viewModel: PostsViewModel
    var post: Post
    
    @ObservedObject var userViewModel: UserViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var peopleIn: Int = 0
    
    @State private var address: String?
    @State var showPostOptions = false
    
    var body: some View {
        
        NavigationView{
            ZStack(alignment: .bottom) {
                
                ScrollView{
                    LazyVStack(alignment: .leading, spacing: 15) {
                        
                        Image(post.imageUrl)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 500)
                            .clipped()
                        
                        Group{
                            
                            Text(post.title)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            
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
                                    
                                    if let fullName = post.user?.fullname{
                                        
                                        Text(fullName)
                                            .font(.body)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    if let title = post.user?.title {
                                        Text(title)
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .fontWeight(.bold)
                                    } else if let from = post.user?.from{
                                        Text(from)
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .fontWeight(.bold)
                                    }
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
                                        
                                        if post.peopleIn.contains(userViewModel.user.id) || post.accessability == .Public{
                                            Text("Bulgaria, Sofia")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            Text("St. Georg Washington")
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                                .fontWeight(.bold)
                                        } else {
                                            Text("The exact location will be revealed upon joining.")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                    }
                                }
                                
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "person.3")
                                        .imageScale(.large)
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Participants \(post.peopleIn.count)/\(post.maximumPeople)")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        
                                        if post.participants.count > 0 {
                                            ZStack{
                                                ForEach(0..<post.participants.count, id: \.self){ number in
                                                    
                                                    if let image = post.participants[number].profileImageUrl {
                                                        
                                                        Image(image[0])
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
                                            }
                                            
                                            if post.peopleIn.count >= 4 {
                                                
                                                Circle()
                                                    .fill(.gray)
                                                    .frame(width: 40, height: 40)
                                                    .overlay(
                                                        ZStack(alignment:.center){
                                                            Text("\(post.peopleIn.count - 4)")
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
                            
                            if post.peopleIn.contains(userViewModel.user.id) || post.accessability == .Public{
                                
                                Text(address ?? "-/--")
                                    .normalTagTextStyle()
                                    .normalTagCapsuleStyle()
                                    .onAppear{
                                        reverseGeocode(coordinate: CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude)) { result in
                                            address = result
                                        }
                                    }
                                
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
                                    Text(interest)
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
                
                VStack{
                    
                    Divider()
                    
                    HStack{
                        Button {
                            viewModel.likePost(postID: post.id, userID: userViewModel.user.id, user: userViewModel.user)
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
                        
                        Button {
                            print("Join")
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
                    }
                    .padding(.horizontal)
                    
                }
                .background(.bar)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:Button(action: {dismiss()}) {
                Image(systemName: "chevron.left")
            }, trailing:Button(action: {
                showPostOptions = true
                viewModel.clickedPostIndex = viewModel.posts.firstIndex(of: post) ?? 0
            }, label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
            })
            )
        }
        .sheet(isPresented: $showPostOptions, content: {
            List {
                Button("Save") {
                    viewModel.selectedOption = "Save"
                }
                
                Button("Share via") {
                    viewModel.selectedOption = "Share"
                }
                
                Button("Report") {
                    viewModel.selectedOption = "Report"
                }
            }
            .presentationDetents([.fraction(0.4)])
            .presentationDragIndicator(.visible)
        })
        .onAppear {
            self.peopleIn = post.peopleIn.count
        }
    }
    
}



struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(viewModel: PostsViewModel(), post: Post.MOCK_POSTS[0], userViewModel: UserViewModel())
    }
}
