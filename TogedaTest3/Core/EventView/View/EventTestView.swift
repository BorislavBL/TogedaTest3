//
//  EventTestView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import MapKit
import WrappingHStack

struct EventTestView: View {
    @ObservedObject var viewModel: PostsViewModel
    var post: Post
    
    @ObservedObject var userViewModel = UserViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var peopleIn: Int = 0

    let location = Location(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
    
    
    @State private var address: String?
    
    var body: some View {
        NavigationView {
            
            ZStack(alignment: .bottom) {
                
                ScrollView{
                    LazyVStack(alignment: .leading, spacing: 15) {
                        
                        Image(post.imageUrl[0])
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
                                        Text("Bulgaria, Sofia")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        Text("St. Georg Washington")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .fontWeight(.bold)
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
                                        Text(post.type.capitalized)
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
                            
                            Text(address ?? "-/--")
                                .normalTagTextStyle()
                                .normalTagCapsuleStyle()
                                .onAppear{
                                    reverseGeocode(coordinate: location.coordinate) { result in
                                        address = result
                                    }
                                }
                            
//                            MapSlot(name:post.title, location: CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude))
                            
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
                            Text("Join")
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .cornerRadius(10)
                                .fontWeight(.semibold)
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
            }, trailing:Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
            )
        }
        .onAppear {
            self.peopleIn = post.peopleIn.count
        }
    }
    
}


struct EventTestView_Previews: PreviewProvider {
    static var previews: some View {
        EventTestView(viewModel: PostsViewModel(), post: Post.MOCK_POSTS[0], userViewModel: UserViewModel())
    }
}


//{
//    var post: Post
//    @Environment(\.dismiss) private var dismiss
//
//    @StateObject var postViewModel = PostsViewModel()
//
//    let locations = [
//        Location(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
//    ]
//
//    @State private var address: String?
//
//    var body: some View {
//        ZStack(alignment: .bottom){
//            ScrollView {
//                ZStack(alignment: .top){
//                    ZStack(alignment: .bottom) {
//                        // The Image
//                        Image(post.imageUrl)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(height: 500)
//                            .clipped()
//
//                        LinearGradient(gradient: Gradient(colors: [Color("testColor").opacity(0), Color("testColor").opacity(1)]),
//                                       startPoint: .top,
//                                       endPoint: .bottom)
//                        .frame(height: 70)
//                    }
//
//                    //this Vstack
//                    VStack {
//                        Color.clear
//                            .frame(height: 400)
//
//                        VStack (alignment: .leading, spacing: 15) {
//                            Text(post.category)
//                                .font(.body)
//                                .fontWeight(.semibold)
//                                .foregroundColor(.gray)
//
//                            Text(post.title)
//                                .font(.title)
//                                .fontWeight(.bold)
//
//                            HStack(alignment: .top){
//                                VStack(alignment:.leading){
//                                    HStack(spacing: 3) {
//                                        Image(systemName: "calendar")
//                                        Text(postViewModel.separateDateAndTime(from: post.date).date)
//                                            .normalTagTextStyle()
//                                    }
//                                    .normalTagCapsuleStyle()
//
//                                    VStack(alignment: .leading){
//                                        Text("Organizer")
//                                            .font(.body)
//                                            .fontWeight(.semibold)
//
//                                        HStack{
//                                            Image("person_1")
//                                                .resizable()
//                                                .scaledToFill()
//                                                .frame(width: 40, height: 40)
//                                                .clipped()
//                                                .cornerRadius(100)
//
//                                            Text("Alison Hogwards")
//                                                .font(.footnote)
//                                                .foregroundColor(Color("textColor"))
//                                                .fontWeight(.bold)
//                                        }
//                                    }
//                                    .normalTagRectangleStyle()
//
//                                }
//
//                                VStack(alignment:.leading){
//                                    HStack(spacing: 3) {
//                                        Image(systemName: "clock")
//                                        Text(postViewModel.separateDateAndTime(from: post.date).time)
//                                            .normalTagTextStyle()
//                                    }
//                                    .normalTagCapsuleStyle()
//
//                                    VStack(alignment: .leading){
//                                        Text("Participants (\(post.peopleIn.count)/\(post.maximumPeople))")
//                                            .font(.body)
//                                            .fontWeight(.semibold)
//
//                                        ZStack{
//                                            ForEach(0..<5, id: \.self){ number in
//                                                Image("person_1")
//                                                    .resizable()
//                                                    .scaledToFill()
//                                                    .frame(width: 40, height: 40)
//                                                    .clipped()
//                                                    .cornerRadius(100)
//                                                    .overlay(
//                                                        Circle()
//                                                            .stroke(Color("secondaryColor"), lineWidth: 2)
//                                                    )
//                                                    .offset(x:CGFloat(20 * number))
//
//                                            }
//                                        }
//                                    }
//                                    .normalTagRectangleStyle()
//                                }
//                            }
//
//                            Text("Description")
//                                .font(.title3)
//                                .fontWeight(.bold)
//                                .padding(.vertical, 8)
//
//                            ExpandableText(post.description, lineLimit: 4)
//                                .lineSpacing(8.0)
//                                .fontWeight(.medium)
//                                .foregroundColor(.gray)
//                                .padding(.bottom, 8)
//
//                            Text("Location")
//                                .font(.title3)
//                                .fontWeight(.bold)
//                                .padding(.vertical, 8)
//
//                            Text(address ?? "-/--")
//                                .normalTagTextStyle()
//                                .normalTagCapsuleStyle()
//                                .onAppear{
//                                    postViewModel.reverseGeocode(coordinate: locations[0].coordinate) { result in
//                                        address = result
//                                    }
//                                }
//
//                            MapView(locations: locations)
//
//                            Text("Interests")
//                                .font(.title3)
//                                .fontWeight(.bold)
//                                .padding(.vertical, 8)
//
//                            WrappingHStack(alignment: .leading, horizontalSpacing: 5){
//                                ForEach(post.interests, id:\.self){ interest in
//                                    Text(interest)
//                                        .normalTagTextStyle()
//                                        .normalTagCapsuleStyle()
//                                }
//                            }
//
//                        }
//                        .frame(minWidth: 0, maxWidth: .infinity)
//                        .padding()
//                        .padding(.vertical)
//                        .padding(.bottom, 60)
//                        .background(.bar)
//                        .cornerRadius(30)
//                    }
//                }
//            }
//            .frame(minWidth: 0, maxWidth: .infinity)
//            .edgesIgnoringSafeArea(.top)
//            .background(Color("testColor"))
//            .scrollIndicators(.hidden)
//            .navigationBarBackButtonHidden(true)
//            .navigationBarItems(leading:Button(action: {dismiss()}) {
//                Image(systemName: "chevron.left")
//            }, trailing:Image(systemName: "ellipsis")
//                .rotationEffect(.degrees(90))
//            )
//
//            HStack{
//                Button {
//                    print("Join")
//                } label: {
//                    Text("Join")
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 60)
//                        .background(Color("blackAndWhite"))
//                        .foregroundColor(Color("testColor"))
//                        .cornerRadius(10)
//                        .fontWeight(.semibold)
//                }
//
//                Button {
//                    print("Join")
//                } label: {
//                    Image(systemName:"paperplane")
//                        .resizable()
//                        .scaledToFit()
//                        .padding()
//                        .frame(width: 60, height: 60)
//                        .background(Color("secondaryColor"))
//                        .cornerRadius(10)
//                }
//
//                Button {
//                   dismiss()
//                } label: {
//                    Image(systemName:"bookmark")
//                        .resizable()
//                        .scaledToFit()
//                        .padding()
//                        .frame(width: 60, height: 60)
//                        .background(Color("secondaryColor"))
//                        .cornerRadius(10)
//                }
//            }
//            .padding(.horizontal)
//        }
//    }
//
//}
