//
//  MessagePostPreview.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 22.11.23.
//

import SwiftUI
import Kingfisher
import WrappingHStack

struct MessagePostPreview: View {
    let postID: String
    @State var post: Components.Schemas.PostResponseDto?
    var size: CGSize = .init(width: 180, height: 300)
    @State var Init: Bool = true
    @State var loadingCases: LoadingCases = .loading
    
    var body: some View {
        VStack(alignment: .leading){
            if let post = post, loadingCases == .loaded, !post.blockedForCurrentUser{
                NavigationLink(value: SelectionPath.eventDetails(post)) {
                    VStack(alignment: .leading){
                        ZStack(alignment: .bottom) {
                            KFImage(URL(string: post.images[0]))
                                .resizable()
                                .scaledToFill()
                                .frame(size)
                                .clipped()
                            
                            LinearGradient(gradient: Gradient(colors: [.black.opacity(0), .black.opacity(0), .black]), startPoint: .top, endPoint: .bottom)
                                .opacity(0.95)
                            
                            VStack(alignment: .leading){
                                
                                Text(post.title)
                                    .font(.footnote)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                    .padding(.bottom, 5)
                                
                                WrappingHStack(alignment: .leading, verticalSpacing: 5){
                                    if let fromDate = post.fromDate{
                                        HStack{
                                            Image(systemName: "calendar")
                                                .font(.caption)
                                                .foregroundColor(post.status == .HAS_ENDED ? .red : Color("light-gray"))
                                            Text(post.status == .HAS_ENDED ? "Ended" : "\(separateDateAndTime(from: fromDate).date)")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(post.status == .HAS_ENDED ? .red : Color("light-gray"))
                                        }
                                    } else if post.status == .HAS_ENDED {
                                        HStack{
                                            Image(systemName: "calendar")
                                                .font(.caption)
                                                .foregroundColor(post.status == .HAS_ENDED ? .red : Color("light-gray"))
                                            Text("Ended")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.red)
                                        }
                                    }
                                    HStack{
                                        Image(systemName: "person.2.fill")
                                            .font(.caption)
                                            .foregroundColor(Color("light-gray"))
                                        
                                        if let maxPeople = post.maximumPeople {
                                            Text("\(post.participantsCount)/\(maxPeople)")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color("light-gray"))
                                        } else {
                                            Text("\(post.participantsCount)")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color("light-gray"))
                                        }
                                    }
                                }
                                .padding(.bottom, 2)

                                    HStack(alignment: .center){
                                        Image(systemName: "location")
                                            .font(.caption)
                                            .foregroundColor(Color("light-gray"))
                                        
                                        Text(locationCityAndCountry(post.location))
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color("light-gray"))
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                
                            }
                            
                            .padding(.horizontal, 12)
                            .padding(.vertical)
                            .frame(maxWidth: size.width, maxHeight: size.height, alignment: .bottomLeading)
                 
                        }
                        .frame(size)
                        .cornerRadius(20)
                        
                    }
                }
            } else if let post = post, post.blockedForCurrentUser {
                VStack(alignment: .center){
                    Text("No such event")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .opacity(0.5)
                }
                .frame(size)
            } else if loadingCases == .noResults{
                VStack(alignment: .center){
                    Text("No such event")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .opacity(0.5)
                }
                .frame(size)
            } else {
                ProgressView()
                    .frame(size)
            }
        }
        .frame(width: size.width)
        .background(Color("SecondaryBackground"))
        .cornerRadius(20)
        .onAppear(){
            Task{
                if Init{
                    do{
                        if let response = try await APIClient.shared.getEvent(postId: postID, showBanners: false) {
                            self.post = response
                            self.loadingCases = .loaded
                            self.Init = false
                            print("here")
                            
                        } else {
                            print("no its here")
                            self.loadingCases = .noResults
                        }
                    } catch {
                        self.loadingCases = .noResults
                    }
                }
            }
        }
        
    }
}

#Preview {
    MessagePostPreview(postID: "")
}
