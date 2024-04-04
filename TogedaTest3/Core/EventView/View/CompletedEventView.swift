//
//  CompletedEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 31.10.23.
//

import SwiftUI
import MapKit
import WrappingHStack
import PhotosUI

struct CompletedEventView: View {
    @StateObject var photoPickerVM = PhotoPickerViewModel()
    @EnvironmentObject var viewModel: PostsViewModel
    var postID: String
    var post: Post? {
        return viewModel.posts.first(where: {$0.id == postID})
    }
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var peopleIn: Int = 0
    
    @State private var address: String?
    @State var showPostOptions = false
    let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
    let images: [String] = ["event_1", "event_2", "event_3", "event_4"]
    @State var showImageViewer: Bool = false
    @State var selectedImage: Int = 0
    
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
                                    .frame(width: UIScreen.main.bounds.width)
                                    .clipped()
                                
                            }
                            
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .frame(height: UIScreen.main.bounds.width * 1.5)
                        
                        VStack(alignment:.leading) {
                            
                            Text(post.title)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            
                            if let user = post.user {
                                NavigationLink(value: SelectionPath.profile(user)){
                                    HStack(alignment: .center, spacing: 10) {
                                        if let image = post.user?.profilePhotos {
                                            Image(image[0])
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 60, height: 60)
                                                .clipped()
                                                .cornerRadius(15)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 5) {
                                            
                                            if let user = post.user{
                                                
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
                                NavigationLink(value: SelectionPath.club(club)){
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
                                        
                                        
                                        Text("Bulgaria, Sofia")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        Text("St. Georg Washington")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .fontWeight(.bold)
                                    }
                                }
                                
                                
                                NavigationLink(value: SelectionPath.completedEventUsersList(users: post.participants)){
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
                                            }
                                            
                                            
                                            if post.participants.count > 0 {
                                                ZStack{
                                                    ForEach(0..<post.participants.count, id: \.self){ number in
                                                        
                                                        Image(post.participants[number].profilePhotos[0])
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
                                                    
                                                    if post.peopleIn.count >= 4 {
                                                        
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
                                        Text(post.accessability.capitalized)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        Text("Everyone can join the event")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .fontWeight(.bold)
                                    }
                                }
                                
                                if post.hasEnded, let rating = post.rating {
                                    HStack(alignment: .center, spacing: 10) {
                                        Image(systemName: "star")
                                            .imageScale(.large)
                                        
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("Rating \(rating, specifier: "%.2f")")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            RatingView(rating: .constant(Int(round(rating))))
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
                            
                            Text("Memories")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.vertical, 8)
                            
                            MemoriesTab(images: images, selectedImage: $selectedImage, showImagesViewer: $showImageViewer)
                            
                            Text("Location")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.vertical, 8)
                            
                            
                            Text(address ?? "-/--")
                                .normalTagTextStyle()
                                .normalTagCapsuleStyle()
                            
                            MapSlot(name:post.title, latitude: post.location.latitude, longitude: post.location.longitude)
                            
                            
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
                
                VStack{
                    navbar()
                    
                    Spacer()
                    
                    VStack{
                        Divider()
                        
                        HStack{
                            Button {
                                photoPickerVM.showPhotosPicker = true
                            } label: {
                                HStack{
                                    Image(systemName: "photo")
                                        .foregroundColor(Color("testColor"))
                                    
                                    Text("Add Images")
                                    
                                }
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        
                    }
                    .background(.bar)
                }
            }
            .navigationBarBackButtonHidden(true)
            .photosPicker(isPresented: $photoPickerVM.showPhotosPicker, selection: $photoPickerVM.imagesSelection, matching: .images)
            .sheet(isPresented: $showPostOptions, content: {
                List {
                    Button("Report") {
                        viewModel.selectedOption = "Report"
                    }
                    
                    if let user = post.user, user.id == userId {
                        Button("Delete") {
                            viewModel.selectedOption = "Delete"
                        }
                    }
                }
                .presentationDetents([.fraction(0.2)])
                .presentationDragIndicator(.visible)
            })
            .fullScreenCover(isPresented: $showImageViewer, content: {
                ImageViewer(images: images, selectedImage: $selectedImage)
            })
            .onAppear {
                self.peopleIn = post.peopleIn.count
                reverseGeocode(coordinate: CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude)) { result in
                    address = result
                }
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
    
}

#Preview {
    CompletedEventView(postID: Post.MOCK_POSTS[0].id)
        .environmentObject(UserViewModel())
        .environmentObject(PostsViewModel())
}
