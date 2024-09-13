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
    @Published var listSize: Int32 = 15
    @Published var isLoading = false
    
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
            }
        }
    }
}

struct ShareView: View {
    @StateObject var vm = ShareViewModel()
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userVM: UserViewModel

    let size: ImageSize = .small
    var post: Components.Schemas.PostResponseDto?
    var club: Components.Schemas.ClubDto?
    
    var body: some View {
        VStack {
            HStack(spacing: 16){
                CustomSearchBar(searchText: $vm.searchText, showCancelButton: $vm.showCancelButton)
                    
                
                if !vm.showCancelButton {
                        ShareLink("", item: URL(string: createURLLink(postID: post?.id, clubID: club?.id, userID: nil))!)

                }
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
                                vm.isLoading = true
                                Task{
                                    try await vm.fetchList()
                                    vm.isLoading = false
                                    
                                }
                            }
                            
                        }
                    
                }
            }
            
            if vm.selectedChatRooms.count > 0 {
                VStack{
                    Button{
                        Task{
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
                }
                .padding(.horizontal)
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
                        if chatroom.previewMembers.count > 1 {
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
}
