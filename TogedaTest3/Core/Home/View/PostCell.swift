//
//  PostCell.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import WrappingHStack
import Kingfisher

struct PostCell: View {
    var post: Components.Schemas.PostResponseDto
    
    var body: some View {
        PostCellSkeleton(post: post)
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color("postCellColor"))
        .cornerRadius(10)
        .padding(.horizontal, 8)
    }

}

struct PostCellSkeleton: View {
    @EnvironmentObject var viewModel: PostsViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    var post: Components.Schemas.PostResponseDto
    
    var body: some View {
        VStack(alignment: .center, spacing: 15){
            ZStack(alignment: .top){
                VStack(alignment: .center, spacing: 15){
                    headerSpacer()
                        .opacity(0)
                    
//                    NavigationLink(value: SelectionPath.eventDetails(post)) {
                    GeometryReader { geometry in
                        KFImage.url(URL(string: post.images[0])!)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 400)
                            .frame(maxWidth: geometry.size.width)
                            .clipShape(
                                RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                            )
                            .overlay(
                                NavigationLink(value: SelectionPath.eventDetails(post)) {
                                    Rectangle()
                                        .frame(height: 400)
                                        .opacity(0)
                                }
                            )
                    }
                    .frame(height: 400)
//                    }
                }

                
                //MARK: - Post Header
                HStack(alignment: .center) {
//                    NavigationLink(value: SelectionPath.profile(post.owner)) {
                        HStack(alignment: .center) {
                            
//                            AsyncImage(url: URL(string: post.owner.profilePhotos[0])) { image in
//                                image
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(width: 50, height: 50)
//                                    .background(.gray)
//                                    .cornerRadius(15)
//                            } placeholder: {
//                                Color.gray
//                                    .frame(width: 50, height: 50)
//                                    .background(.gray)
//                                    .cornerRadius(15)
//                            }
                            
                            KFImage(URL(string: post.owner.profilePhotos[0]))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .background(.gray)
                                .cornerRadius(15)
//                                .overlay(alignment: .bottomTrailing) {
//                                    AmbassadorSealMini()
//                                        .offset(x: 3, y: 3)
//                                }
                            
                            
                            VStack(alignment: .leading, spacing: 3){
//                                HStack(spacing: 5){
                                    Text(post.title)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                    
//                                    AmbassadorSealMini()
//                                }
                                
                                HStack(spacing: 5){
                                    Text("\(post.owner.firstName) \(post.owner.lastName)")
                                        .foregroundColor(.gray)
                                        .fontWeight(.semibold)
                                        .font(.footnote)
                                    
                                    if post.owner.userRole == .AMBASSADOR {
                                        AmbassadorSealMiniature()
                                    } else if post.owner.userRole == .PARTNER {
                                        PartnerSealMiniature()
                                    }
                                }
                                

                            }
                        }
                        .overlay(
                            NavigationLink(value: SelectionPath.profile(post.owner)) {
                                headerSpacer()
                                    .opacity(0)
                            }
                        )
                        
//                    }
                    
                    Spacer()
                    
                    //MARK: - Post Options
                    
                    Menu{
                        ShareLink(item: URL(string: createURLLink(postID: post.id, clubID: nil, userID: nil))!) {
                            Text("Share via")
                        }
                        //
                        if isOwner {
                            
                        } else {
                            Button("Report") {
                                viewModel.showReportEvent = true
                                viewModel.clickedPost = post
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .padding(8)
                    }
                    
                }
            }
            
            //MARK: - Buttons
            
            HStack(alignment: .center, spacing: 20){
                Button {
                    viewModel.clickedPost = post
                    if post.payment > 0, !isOwner, post.currentUserStatus == .NOT_PARTICIPATING, post.status == .NOT_STARTED {
                        Task{
                            if let response = try await APIClient.shared.getEvent(postId: post.id){
                                viewModel.localRefreshEventOnAction(post: response)
                                
                                if let max = response.maximumPeople, max <= response.participantsCount{
                                    viewModel.showJoinRequest = true
                                } else {
                                    viewModel.showPaymentView = true
                                }
                            } else {
                                viewModel.showPaymentView = true
                            }
                        }
                    } else {
                        viewModel.showJoinRequest = true
                    }
                } label: {
                    if post.currentUserStatus == .PARTICIPATING || post.currentUserStatus == .IN_QUEUE {
                        Image(systemName: "person.2.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    } else {
                        Image(systemName: "person.2.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                }
                
                if post.currentUserStatus == .PARTICIPATING || !post.askToJoin {
                    
                    Button{
                        let url = URL(string: "maps://?saddr=&daddr=\(post.location.latitude),\(post.location.longitude)")
                        if UIApplication.shared.canOpenURL(url!) {
                            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                        }
                    } label: {
                        Image(systemName: "mappin.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                } else {
                    Image(systemName: "mappin.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(.gray)
                }
                
                Button {
                    viewModel.clickedPost = post
                    viewModel.showSharePostSheet = true
                } label: {
                    
                    Image(systemName: "paperplane")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                }
                
                Spacer()
                
                Button {
                    Task{
                        try await viewModel.saveEvent(postId: post.id)
                    }
                } label: {
                    Image(systemName: post.savedByCurrentUser ? "bookmark.fill" : "bookmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                }
                
            }
            .foregroundColor(Color("textColor"))
            
            //MARK: - Tags
            PostTags(post: post)
        }
    }
    
    
    // This view is used to create the perfect height of the header.
    //The reason thats needed its because the clipped image overlaps the menu button and it doesnt trigger. That minght be fixed in future versions so check regularly.
    
    func headerSpacer() -> some View {
            HStack(alignment: .center) {
                Rectangle()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.gray)
                    .cornerRadius(15)
                
                
                VStack(alignment: .leading, spacing: 3){
                    Text(post.title)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    Text("\(post.owner.firstName) \(post.owner.lastName)")
                        .foregroundColor(.gray)
                        .fontWeight(.semibold)
                        .font(.footnote)
                }
                
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .padding(8)
            }
            
    }
    
    var isOwner: Bool {
        if let currentUser = userViewModel.currentUser, currentUser.id == post.owner.id{
            return true
        } else {
            return false
        }
    }
}

struct PostCell_Previews: PreviewProvider {
    static var previews: some View {
        PostCell(post: MockPost)
            .environmentObject(PostsViewModel())
            .environmentObject(UserViewModel())
    }
}
