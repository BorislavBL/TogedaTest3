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
    @ObservedObject var viewModel: PostsViewModel
    var post: Post
    
    @ObservedObject var userViewModel: UserViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var peopleIn: Int = 0
    
    @State private var address: String?
    @State var showPostOptions = false
    let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
    let images: [String] = ["event_1", "event_2", "event_3", "event_4"]
    @State var showImageViewer: Bool = false
    @State var selectedImage: Int = 0
    
    var body: some View {
        
        NavigationView{
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
                                    .onAppear{
                                        reverseGeocode(coordinate: CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude)) { result in
                                            address = result
                                        }
                                    }
                                
                                MapSlot(name:post.title, latitude: post.location.latitude, longitude: post.location.longitude)
                                
                            
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
            .photosPicker(isPresented: $photoPickerVM.showPhotosPicker, selection: $photoPickerVM.imagesSelection, matching: .images)
        }
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
            ImageViewer(images: images, selectedImage: selectedImage)
        })
        .onAppear {
            self.peopleIn = post.peopleIn.count
        }
    }
    
}

#Preview {
    CompletedEventView(viewModel: PostsViewModel(), post: Post.MOCK_POSTS[0], userViewModel: UserViewModel())
}
