//
//  ReviewProfileView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.06.24.
//

import SwiftUI
import Kingfisher

enum RatingTypes {
    case likes
    case rating
}

struct ReviewProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    var user: Components.Schemas.UserInfoDto
    
    @State var isLoading = false
    
    @State var likesList: [Components.Schemas.ParticipationRatingResponseDto] = []
    @State var likesPage: Int32 = 0
    @State var likesSize: Int32 = 15
    @State var likesCount: Int64 = 0
    @State var likesInit: Bool = true
    @State var likesLastPage = true
    
    @State var ratingList: [Components.Schemas.RatingResponseDto] = []
    @State var ratingPage: Int32 = 0
    @State var ratingSize: Int32 = 15
    @State var ratingCount: Int64 = 0
    @State var ratingInit: Bool = true
    @State var ratingLastPage = true
    
    @State var selectedRating: RatingTypes = .likes
    
    @State var rating: Double = 0
    @State var noShows: Int32 = 0
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment: .leading){
                VStack{
                    Text("\(noShows)")
                        .bold()
                        .font(.title)
                    
                    Text("No-Shows (in the last 15 days)")
                        .font(.footnote)
                        .fontWeight(.semibold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color("main-secondary-color"))
                .cornerRadius(10)
                //                .padding(.horizontal)
                
                HStack{
                    Button{
                        selectedRating = .likes
                    } label:{
                        VStack(alignment: .center, spacing: 8) {
                            Text("\(likesCount)")
                                .font(.body)
                                .bold()
                            
                            Text("Likes")
                                .font(.footnote)
                                .bold()
                        }
                        .foregroundStyle(selectedRating == .likes ? Color("base") : Color("blackAndWhite"))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedRating == .likes ? Color("SelectedFilter") : Color("main-secondary-color"))
                        .cornerRadius(10)
                    }
                    
                    Button{
                        selectedRating = .rating
                    } label:{
                        VStack(alignment: .center, spacing: 8) {
                            RatingView(rating: Int(round(rating)), offColor: selectedRating == .rating ? Color("base").opacity(0.3) : Color("blackAndWhite").opacity(0.3), onColor: selectedRating == .rating ? Color("base") : Color("blackAndWhite"))
                                .font(.body)
                                .bold()
                            
                            Text("Ratings")
                                .font(.footnote)
                                .bold()
                        }
                        .foregroundStyle(selectedRating == .rating ? Color("base") : Color("blackAndWhite"))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedRating == .rating ? Color("SelectedFilter") : Color("main-secondary-color"))
                        .cornerRadius(10)
                    }
                }
                //                .padding(.horizontal)
                .padding(.bottom)
                
                Text("Comments:")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
                    .padding(.vertical)
                
                
                
                switch selectedRating {
                case .likes:
                    ForEach(likesList, id: \.id){ response in
                        if let comment = response.comment {
                            HStack(alignment: .top){
                                NavigationLink(value: SelectionPath.profile(response.userFrom)) {
                                    KFImage(URL(string: response.userFrom.profilePhotos[0]))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                }
                                
                                VStack(alignment: .leading) {
                                    HStack(alignment: .center){
                                        Text("\(response.userFrom.firstName) \(response.userFrom.lastName)")
                                            .fontWeight(.semibold)
                                            .font(.footnote)
                                        
                                        Image(systemName: "hand.thumbsup.fill")
                                            .foregroundStyle(.green)
                                            .imageScale(.small)
                                    }
                                    
                                    Text(comment)
                                        .font(.footnote)
                                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color("main-secondary-color"))
                                .cornerRadius(10)
                            }
                        }
                    }
                case .rating:
                    LazyVStack(alignment:. leading, spacing: 15) {
                        ForEach(ratingList, id: \.id){ response in
                            if let comment = response.comment {
                                HStack(alignment: .top){
                                    NavigationLink(value: SelectionPath.profile(response.user)) {
                                        KFImage(URL(string: response.user.profilePhotos[0]))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        VStack(alignment: .leading) {
                                            HStack(alignment: .center){
                                                Text("\(response.user.firstName) \(response.user.lastName)")
                                                    .fontWeight(.semibold)
                                                    .font(.footnote)
                                                
                                                RatingView(rating: Int(round(response.value)), onColor: Color.orange, dimension: 10)
                                                
                                            }
                                            
                                            ExpandableText(comment)
                                                .font(.footnote)
                                                .lineLimit(4)
                                                .moreButtonText("read more")
                                                .moreButtonFont(.system(.footnote, design: .rounded).bold())
                                                .trimMultipleNewlinesWhenTruncated(false)
                                                .enableCollapse(true)
                                                .hasAnimation(false)
                                                .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                                            //                                    Text(comment)
                                            //                                        .font(.footnote)
                                            //                                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                                        }
                                        .padding(8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color("main-secondary-color"))
                                        .cornerRadius(10)
                                        
                                        postTag(post: response.post)
                                    }
                                }
                                
                            }
                            
                        }
                    }
                }
                
                switch selectedRating {
                case .likes:
                    ListLoadingButton(isLoading: $isLoading, isLastPage: likesLastPage) {
                        Task{
                            defer{isLoading = false}
                            if !likesLastPage{
                                if let response = try await APIClient.shared.getUserLikesList(userId: user.id, page: likesPage, size: likesSize) {
                                    let newResponse = response.data
                                    let existingResponseIDs = Set(self.likesList.suffix(30).map { $0.id })
                                    let uniqueNewResponse = newResponse.filter { !existingResponseIDs.contains($0.id) }
                                    
                                    
                                    likesList += uniqueNewResponse
                                    likesPage += 1
                                    likesLastPage = response.lastPage
                                    likesCount = response.listCount
                                    
                                    likesInit = false
                                }
                            }
                        }
                    }
                case .rating:
                    ListLoadingButton(isLoading: $isLoading, isLastPage: ratingLastPage) {
                        Task{
                            defer{isLoading = false}
                            if  !ratingLastPage{
                                if let response = try await APIClient.shared.getRatingForProfile(userId: user.id, page: ratingPage, size: ratingSize) {
                                    let newResponse = response.data
                                    let existingResponseIDs = Set(self.ratingList.suffix(30).map { $0.id })
                                    let uniqueNewResponse = newResponse.filter { !existingResponseIDs.contains($0.id) }
                                    
                                    
                                    ratingList += uniqueNewResponse
                                    ratingPage += 1
                                    ratingLastPage = response.lastPage
                                    ratingCount = response.listCount
                                }
                            }
                        }
                    }
                }
                
                
                
            }
            .padding()
            .onChange(of: selectedRating){
                isLoading = false
                if selectedRating == .rating{
                    if ratingInit{
                        Task{
                            if let response = try await APIClient.shared.getRatingForProfile(userId: user.id, page: ratingPage, size: ratingSize) {
                                
                                let newResponse = response.data
                                let existingResponseIDs = Set(self.ratingList.suffix(30).map { $0.id })
                                let uniqueNewResponse = newResponse.filter { !existingResponseIDs.contains($0.id) }
                                
                                ratingList += uniqueNewResponse
                                ratingPage += 1
                                ratingLastPage = response.lastPage
                                ratingCount = response.listCount
                                
                                ratingInit = false
                                
                            }
                        }
                        
                    }
                }
            }
        }
        .background(.bar)
        .navigationTitle("Reputation")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
        .swipeBack()
        .onAppear(){
            Task{
                if likesInit{
                    try await fetchAllInitialData(userId: user.id)
                }
            }
        }
        
        
    }
    
    @ViewBuilder
    func postTag(post: Components.Schemas.PostResponseDto) -> some View {
        NavigationLink(value: SelectionPath.eventDetails(post)) {
            HStack{
                KFImage(URL(string: post.images[0]))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
                
                Text(post.title)
                    .fontWeight(.medium)
                    .font(.footnote)
                    .opacity(0.8)
            }
            .frame(height: 16)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background{Capsule().fill(Color("main-secondary-color").opacity(0.5))}
        }
    }
    
    func fetchAllInitialData(userId: String) async throws{
        // Use a task group to fetch all data concurrently
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    if let response = try await APIClient.shared.getUserLikesList(userId: user.id, page: likesPage, size: likesSize) {
                        DispatchQueue.main.async {
                            self.likesList = response.data
                            self.likesPage += 1
                            self.likesLastPage = response.lastPage
                            self.likesCount = response.listCount
                            
                            self.likesInit = false
                        }
                        
                    }
                } catch {
                    print("Error fetching user posts: \(error)")
                }
            }
            group.addTask {
                do {
                    if let resposne = try await APIClient.shared.getUserRatingAvg(userId: user.id) {
                        if let rating = resposne.averageRating {
                            DispatchQueue.main.async {
                                self.rating = rating
                            }
                        }
                    }
                }
                catch {
                    print("Error fetching user posts: \(error)")
                }
            }
            
            group.addTask {
                do {
                    if let response = try await APIClient.shared.getUserNoShows(userId: userId) {
                        DispatchQueue.main.async{
                            self.noShows = response
                        }
                    }
                } catch {
                    print("Error fetching user posts: \(error)")
                }
            }
        }
    }
}

#Preview {
    ReviewProfileView(user: MockUser)
        .environmentObject(UserViewModel())
}
