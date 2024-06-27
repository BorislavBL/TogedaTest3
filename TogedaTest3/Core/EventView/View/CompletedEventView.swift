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
import Kingfisher

struct CompletedEventView: View {
    @StateObject var eventVM = EventViewModel()
    @StateObject var photoPickerVM = PhotoPickerViewModel(s3BucketName: .post, mode: .normal)
    @EnvironmentObject var viewModel: PostsViewModel
    var post: Components.Schemas.PostResponseDto
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State var showPostOptions = false
    let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
    let images: [String] = ["event_1", "event_2", "event_3", "event_4"]
    @State var showImageViewer: Bool = false
    @State var selectedImage: Int = 0
    
    @State var club: Components.Schemas.ClubDto?
    @State var Init = true
    
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
                    
                    VStack(alignment:.leading) {
                        
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
                        
                        if let club = self.club {
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
                                    
                                    
                                    Text(locationCityAndCountry(post.location))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
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
                            
                            if post.status == .HAS_ENDED, let rating = post.rating {
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "star")
                                        .imageScale(.large)
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Rating \(rating, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        RatingView(rating: Int(round(rating)))
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
                        
                        
                        Text(locationAddress(post.location))
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
        .onAppear(){
            Task{
                do {
                    eventVM.participantsList = []
                    eventVM.participantsPage = 0
                    try await eventVM.fetchUserList(id: post.id)
                    if Init{
                        if let clubId = post.clubId, let response = try await APIClient.shared.getClub(clubID: clubId){
                            self.club = response
                            
                            Init = false
                        }
                    }
                } catch {
                    print("Failed to fetch user list: \(error)")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .photosPicker(isPresented: $photoPickerVM.showPhotosPicker, selection: $photoPickerVM.imagesSelection, matching: .images)
        .sheet(isPresented: $showPostOptions, content: {
            List {
                Button("Report") {
                    viewModel.selectedOption = "Report"
                }
                
                if let user = userViewModel.currentUser, user.id == post.owner.id {
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
                viewModel.clickedPost = post
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
    CompletedEventView(post: MockPost, club: MockClub)
        .environmentObject(UserViewModel())
        .environmentObject(PostsViewModel())
}
