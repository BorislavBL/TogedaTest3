//
//  SharePostView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 4.12.23.
//

import SwiftUI
import WrappingHStack
import Kingfisher
import Combine

class ShareViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var cancellable: AnyCancellable?
    @Published var searchPage: Int32 = 0
    
    @Published var searchChatRoomsResults: [Components.Schemas.ChatRoomDto] = []
    @Published var selectedChatRooms: [Components.Schemas.ChatRoomDto] = []
    @Published var showCancelButton: Bool = false
    
    @Published var chatRoomsList: [Components.Schemas.ChatRoomDto] = []
    @Published var lastPage: Bool = true
    @Published var page: Int32 = 0
    @Published var listSize: Int32 = 30
    @Published var isLoading: LoadingCases = .noResults
    @Published var loadingState: LoadingCases = .loading
    
    init() {
        cancellable = $searchText
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { value in
                if !value.isEmpty {
                    print("Searching...")
                    Task{
                        try await self.searchChats()
                    }
                } else {
                    print("Not Searching...")
                    DispatchQueue.main.async {
                        self.searchChatRoomsResults = self.chatRoomsList
                    }
                }
            })
    }
    
    func stopSearch() {
        cancellable?.cancel()
    }
    
    func searchChats() async throws {
        if let response = try await APIClient.shared.searchChatRoom(searchText: searchText, page: searchPage, size: 50) {
            DispatchQueue.main.async {
                self.searchChatRoomsResults = response.data
            }
           
        }
    }
    
    func fetchList() async throws {
        if let response = try await APIClient.shared.allChatsRooms(page: self.page, size: self.listSize) {
            DispatchQueue.main.async {
                let newResponse = response.data
                let existingResponseIDs = Set(self.chatRoomsList.suffix(30).map { $0.id })
                let uniqueNewResponse = newResponse.filter { !existingResponseIDs.contains($0.id) }
                
                self.chatRoomsList += uniqueNewResponse
                self.page += 1
                self.lastPage = response.lastPage
                self.loadingState = .loaded
                if response.lastPage && self.chatRoomsList.count == 0{
                    self.loadingState = .noResults
                }
                self.isLoading == .loaded
            }
        } else {
            DispatchQueue.main.async {
                
                self.loadingState = .noResults
            }
        }
    }
}

struct ShareView: View {
    @StateObject var vm = ShareViewModel()
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var postVM: PostsViewModel
    @State var screenshot: UIImage? = nil

    let size: ImageSize = .small
    var post: Components.Schemas.PostResponseDto?
    var club: Components.Schemas.ClubDto?
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack{
            VStack {
                HStack(spacing: 16){
                    CustomSearchBar(searchText: $vm.searchText, showCancelButton: $vm.showCancelButton)
                }
                .padding()
                
                ScrollView {
                    
                    if vm.selectedChatRooms.count > 0{
                        ScrollView{
                            WrappingHStack(alignment: .topLeading){
                                ForEach(vm.selectedChatRooms, id: \.id) { chatroom in
                                    ChatRoomTags(chatroom: chatroom) {
                                        vm.selectedChatRooms.removeAll(where: { $0 == chatroom })
                                    }
                                    
                                }
                            }
                        }
                        .padding()
                        .frame(maxHeight: 100)
                    }
                    
                    LazyVStack {
                        if vm.searchText.isEmpty{
                            VStack{
                                ShareLink( item: URL(string: createURLLink(postID: post?.id, clubID: club?.id, userID: nil))!) {
                                    HStack{
                                        
                                        
                                        Image(systemName: "link")
                                            .foregroundStyle(.white)
                                            .frame(width: 50, height: 50)
                                            .background{
                                                Circle().foregroundStyle(.blue)
                                            }
                                        
                                        VStack(alignment: .leading){
                                            Text("Copy link")
                                                .fontWeight(.bold)
                                            
                                            Text("Share with your friends!")
                                                .font(.footnote)
                                                .foregroundStyle(.gray)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal)
                                
                                if let post = post, canOpenInstagram() {
                                    VStack{
                                        Button(action: {
                                            dismiss()
                                            withAnimation {
                                                postVM.showInstaOverlay = true
                                            }
                                            
                                        }) {
                                            HStack{
                                                Image("instagram")
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                                    .clipShape(Circle())
                                                
                                                VStack(alignment: .leading){
                                                    Text("Add as a story")
                                                        .fontWeight(.bold)
                                                    
                                                    Text("Share with your friends on instagram!")
                                                        .font(.footnote)
                                                        .foregroundStyle(.gray)
                                                        .multilineTextAlignment(.leading)
                                                }
                                                Spacer()
                                            }
                                            
                                        }
                                        
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.bottom)
                        }
                        
                        if vm.searchChatRoomsResults.count > 0{
                            ForEach(vm.searchChatRoomsResults, id: \.id) { chatroom in
                                VStack {
                                    Button{
                                        if vm.selectedChatRooms.contains(chatroom) {
                                            vm.selectedChatRooms.removeAll(where: { $0 == chatroom })
                                        } else {
                                            vm.selectedChatRooms.append(chatroom)
                                        }
                                        
                                        if !vm.chatRoomsList.contains(chatroom) {
                                            vm.chatRoomsList.insert(chatroom, at: 0)
                                        }
                                    } label:{
                                        chatRoomLabel(chatroom: chatroom)
                                    }
                                    
                                    Divider()
                                        .padding(.leading, 40)
                                }
                                .padding(.leading)
                            }
                            
                            Rectangle()
                                .frame(width: 0, height: 0)
                                .onAppear {
                                    if !vm.lastPage && !vm.searchText.isEmpty{
                                        if vm.isLoading == .loaded {
                                            vm.isLoading = .loading
                                            Task{
                                                try await vm.fetchList()
                                            }
                                        }
                                    }
                                    
                                }
                        } else if vm.loadingState == .noResults {
                            VStack(spacing: 15){
                                Text("📣")
                                    .font(.custom("image", fixedSize: 120))
                                
                                Text("Nothing to share yet! Join some events and clubs or make new friends to start spreading the word!")
                                    .font(.body)
                                    .foregroundStyle(.gray)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom)
                                
                            }
                            .padding(.all)
                            .frame(maxHeight: .infinity, alignment: .center)
                        }
                        
                    }
                }
                
                if vm.selectedChatRooms.count > 0 {
                    VStack{
                        if !isLoading {
                            Button{
                                isLoading = true
                                Task{
                                    defer {
                                        isLoading = false
                                    }
                                    if let post = post {
                                        let chatRoomsIDs: Components.Schemas.ChatRoomIdsDto = Components.Schemas.ChatRoomIdsDto.init(chatRoomIds: vm.selectedChatRooms.map { chatroom in
                                            return chatroom.id
                                        })
                                        if let response = try await APIClient.shared.shareEvent(postId: post.id, chatRoomIds: chatRoomsIDs) {
                                            print("\(response)")
                                            dismiss()
                                        }
                                    }
                                    
                                    else if let club = club {
                                        let chatRoomsIDs: Components.Schemas.ChatRoomIdsDto = Components.Schemas.ChatRoomIdsDto.init(chatRoomIds: vm.selectedChatRooms.map { chatroom in
                                            return chatroom.id
                                        })
                                        if let response = try await APIClient.shared.shareClub(clubId: club.id, chatRoomIds: chatRoomsIDs) {
                                            print("\(response)")
                                            dismiss()
                                        }
                                    }
                                    
                                }
                            } label: {
                                Text("Send")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .fontWeight(.semibold)
                                
                            }
                            .cornerRadius(10)
                            .padding(.top)
                        } else {
                            Text("Loading ...")
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .fontWeight(.semibold)
                                .cornerRadius(10)
                                .padding(.top)
                        }
                    }
                    .padding(.horizontal)
                }
                
                
            }
        }
        .onChange(of: vm.chatRoomsList, { oldValue, newValue in
            if vm.searchText.isEmpty {
                vm.searchChatRoomsResults = newValue
            }
        })
        .onAppear(){
            Task{
                try await vm.fetchList()
            }
        }
        .onDisappear(){
            vm.stopSearch()
        }
    }

    func canOpenInstagram() -> Bool {
        let url = URL(string: "instagram-stories://share")!
        return UIApplication.shared.canOpenURL(url)
    }
    
    @ViewBuilder
    func chatRoomLabel(chatroom: Components.Schemas.ChatRoomDto) -> some View {
        HStack {
            if vm.selectedChatRooms.contains(where: {$0.id == chatroom.id}){
                Image(systemName: "checkmark.circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(.blue)
            } else {
                Image(systemName: "circle")
                    .imageScale(.large)
                    .foregroundStyle(.gray)
            }
            
            
            switch chatroom._type{
            case .CLUB:
                if let club = chatroom.club {
                    KFImage(URL(string: club.images[0]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                }
            case .FRIENDS:
                if chatroom.previewMembers.count > 0 {
                    KFImage(URL(string: chatroom.previewMembers[0].profilePhotos[0]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                }
            case .GROUP:
                if let image = chatroom.image {
                    KFImage(URL(string: image))
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                } else if chatroom.previewMembers.count > 1 {
                    ZStack(alignment:.top){
                        
                        KFImage(URL(string: chatroom.previewMembers[0].profilePhotos[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 2 * size.dimension/3, height: 2 * size.dimension/3)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color("base"), lineWidth: 2)
                            )
                            .offset(y: -size.dimension/6)
                        
                        KFImage(URL(string: chatroom.previewMembers[1].profilePhotos[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 2 * size.dimension/3, height: 2 * size.dimension/3)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color("base"), lineWidth: 2)
                            )
                            .offset(x: size.dimension/6, y: size.dimension/6)
                        
                    }
                    .offset(y: size.dimension/6)
                    .padding([.trailing, .bottom], size.dimension/3)
                }
            case .POST:
                if let post = chatroom.post {
                    KFImage(URL(string: post.images[0]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                }
                
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack{
                    switch chatroom._type{
                    case .CLUB:
                        if let club = chatroom.club {
                            Text("\(club.title)")
                                .lineLimit(1)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    case .FRIENDS:
                        if chatroom.previewMembers.count > 0 {
                            Text("\(chatroom.previewMembers[0].firstName) \(chatroom.previewMembers[0].lastName)")
                                .lineLimit(1)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    case .GROUP:
                        if let title = chatroom.title {
                            Text("\(title)")
                                .lineLimit(1)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        else if chatroom.previewMembers.count > 1 {
                            Text("\(chatroom.previewMembers[0].firstName), \(chatroom.previewMembers[1].firstName)")
                                .lineLimit(1)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    case .POST:
                        if let post = chatroom.post {
                            Text("\(post.title)")
                                .lineLimit(1)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                    }
                    
                    
                    Spacer(minLength: 10)
                }
            }
            
            
            Spacer()
        }
    }
    
}


struct ChatRoomTags: View {
    var chatroom: Components.Schemas.ChatRoomDto
    let size: ImageSize = .xxSmall
    @State var clicked = false
    var action: () -> Void
    var body: some View {
        if clicked {
            Button{action()} label:{
                HStack{
                    Image(systemName: "xmark")
                        .imageScale(.medium)

                    switch chatroom._type{
                    case .CLUB:
                        if let club = chatroom.club {
                            Text("\(club.title)")
                                .lineLimit(1)
                                .font(.subheadline)
                        }
                    case .FRIENDS:
                        if chatroom.previewMembers.count > 0 {
                            Text("\(chatroom.previewMembers[0].firstName) \(chatroom.previewMembers[0].lastName)")
                                .lineLimit(1)
                                .font(.subheadline)
                        }
                    case .GROUP:
                        if chatroom.previewMembers.count > 1 {
                            Text("\(chatroom.previewMembers[0].firstName), \(chatroom.previewMembers[1].firstName)")
                                .lineLimit(1)
                                .font(.subheadline)
                        }
                    case .POST:
                        if let post = chatroom.post {
                            Text("\(post.title)")
                                .lineLimit(1)
                                .font(.subheadline)
                        }
                        
                    }
                    
                }
                .frame(height: size.dimension)
                .padding(.horizontal, 8)
                .background(Color(.tertiarySystemFill))
                .clipShape(Capsule())
            }
        } else {
            Button{clicked = true} label:{
                HStack(alignment: .center){
                    
                    switch chatroom._type{
                    case .CLUB:
                        if let club = chatroom.club {
                            KFImage(URL(string: club.images[0]))
                                .resizable()
                                .scaledToFill()
                                .frame(width: size.dimension, height: size.dimension)
                                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        }
                    case .FRIENDS:
                        if chatroom.previewMembers.count > 0 {
                            KFImage(URL(string: chatroom.previewMembers[0].profilePhotos[0]))
                                .resizable()
                                .scaledToFill()
                                .frame(width: size.dimension, height: size.dimension)
                                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        }
                    case .GROUP:
                        if chatroom.previewMembers.count > 1 {
                            ZStack(alignment:.top){
                                
                                KFImage(URL(string: chatroom.previewMembers[0].profilePhotos[0]))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 2 * size.dimension/3, height: 2 * size.dimension/3)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color("base"), lineWidth: 2)
                                    )
                                    .offset(y: -size.dimension/6)
                                
                                KFImage(URL(string: chatroom.previewMembers[1].profilePhotos[0]))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 2 * size.dimension/3, height: 2 * size.dimension/3)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color("base"), lineWidth: 2)
                                    )
                                    .offset(x: size.dimension/6, y: size.dimension/6)
                                
                            }
                            .offset(y: size.dimension/6)
                            .padding([.trailing, .bottom], size.dimension/3)
                        }
                    case .POST:
                        if let post = chatroom.post {
                            KFImage(URL(string: post.images[0]))
                                .resizable()
                                .scaledToFill()
                                .frame(width: size.dimension, height: size.dimension)
                                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        }
                        
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack{
                            switch chatroom._type{
                            case .CLUB:
                                if let club = chatroom.club {
                                    Text("\(club.title)")
                                        .lineLimit(1)
                                        .font(.subheadline)
    
                                }
                            case .FRIENDS:
                                if chatroom.previewMembers.count > 0 {
                                    Text("\(chatroom.previewMembers[0].firstName) \(chatroom.previewMembers[0].lastName)")
                                        .lineLimit(1)
                                        .font(.subheadline)
           
                                }
                            case .GROUP:
                                if chatroom.previewMembers.count > 1 {
                                    Text("\(chatroom.previewMembers[0].firstName), \(chatroom.previewMembers[1].firstName)")
                                        .lineLimit(1)
                                        .font(.subheadline)
                 
                                }
                            case .POST:
                                if let post = chatroom.post {
                                    Text("\(post.title)")
                                        .lineLimit(1)
                                        .font(.subheadline)
              
                                }
                                
                            }
                        }
                    }
                }
                .frame(height: size.dimension)
                .padding(.trailing, 8)
                .background(Color(.tertiarySystemFill))
                .clipShape(Capsule())
            }
        }
        
    }
}

#Preview {
    ShareView()
        .environmentObject(UserViewModel())
        .environmentObject(PostsViewModel())
}
