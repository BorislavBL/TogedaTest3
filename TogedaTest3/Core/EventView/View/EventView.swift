//
//  EventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import MapKit
import WrappingHStack
import Kingfisher
import EventKit

struct EventView: View {
    @StateObject var eventVM = EventViewModel()
    
    @State var eventNotFound: Bool = false
    @State var post: Components.Schemas.PostResponseDto
    @State var isEditing = false
    
    @State var showConfirmLocationError: Bool = false
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var postsVM: PostsViewModel
    @EnvironmentObject var activityVM: ActivityViewModel
    @EnvironmentObject var chatVM: WebSocketManager
    @EnvironmentObject var navManager: NavigationManager
    @EnvironmentObject var locationManager: LocationManager
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showSharePostSheet: Bool = false
    @State var showPostOptions = false
    @State var showReportEvent = false
    @State private var showJoinRequest: Bool = false
    @State private var showPaymentSheet: Bool = false
    
    @State var club: Components.Schemas.ClubDto?
    
    @State private var Init = true
    @State private var openCreateEvent = false
    @State var deleteSheet: Bool = false
    
    @State var event: EKEvent?
    @State var store = EKEventStore()
    
    @State private var hideEvent: Bool = false
    
    @State var isShowChangeDateAlert = false
    @State var newDate: Date = Date()
    
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
                    
                    Group{
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
                                    
                                    HStack(spacing: 5){
                                        Text("\(post.owner.firstName) \(post.owner.lastName)")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                        
                                        if post.owner.userRole == .AMBASSADOR {
                                            AmbassadorSealMini()
                                        } else if post.owner.userRole == .PARTNER {
                                            PartnerSealMini()
                                        }
                                    }
                                    
                                    Text(post.owner.occupation)
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.leading)
                                    
                                }
                            }
                        }
                        
                        
                        AllEventTabsView(eventVM: eventVM, post: post, club: club, event: $event, store: $store, locationStatus: $locationManager.authorizationStatus)
                        
                        
                        if let description = post.description {
                            Text("Description")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.vertical, 8)
                            
                            ExpandableText(description)
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.secondary)
                                .lineLimit(4)
                                .moreButtonText("read more")
                                .moreButtonFont(.system(.headline, design: .rounded).bold())
                                .trimMultipleNewlinesWhenTruncated(false)
                                .enableCollapse(true)
                                .hasAnimation(false)
                                .padding(.bottom, 8)
                        }
                        
                        
                        Text("Location")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.vertical, 8)
                        
                        if !post.askToJoin || post.currentUserStatus == .PARTICIPATING{
                            
                            Text(post.location.name)
                                .normalTagTextStyle()
                                .normalTagCapsuleStyle()
                            
                            
                            Button(action: {
                                if isGoogleMapsInstalled() {
                                    eventVM.openMapSheet = true
                                } else {
                                    if let url = URL(string: "maps://?saddr=&daddr=\(post.location.latitude),\(post.location.longitude)"),
                                       UIApplication.shared.canOpenURL(url) {
                                        DispatchQueue.main.async {
                                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                        }
                                    }
                                }
                            }, label: {
                                Map(initialPosition: .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude), latitudinalMeters: 1000, longitudinalMeters: 1000))
                                ){
                                    Marker(post.title, coordinate: CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude))
                                        .tint(.black)
                                }
                                .allowsHitTesting(false)
                                .frame(height: 300)
                                .cornerRadius(20)
                            })
                            
                            
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
            //            .safeAreaInset(edge: .top, spacing: 0) {
            //                Rectangle()
            //                    .fill(.clear)
            //                    .frame(height: 44)
            //            }
            .refreshable {
                Task{
                    do {
                        
                        if let response = try await APIClient.shared.getEvent(postId: post.id) {
                            if let index = postsVM.feedPosts.firstIndex(where: { $0.id == post.id }) {
                                postsVM.feedPosts[index] = response
                            }
                            
                            if let index = activityVM.activityFeed.firstIndex(where: { $0.post?.id == post.id }) {
                                activityVM.activityFeed[index].post = response
                            }
                            
                            post = response
                        }
                        
                        eventVM.participantsList = []
                        eventVM.participantsPage = 0
                        try await eventVM.fetchUserList(id: post.id)
                    } catch {
                        print("Failed to fetch user list: \(error)")
                    }
                }
            }
            .background(Color("testColor"))
            .scrollIndicators(.hidden)
            .edgesIgnoringSafeArea(.top)
            
            VStack {
                navbar()
                
                Spacer()
                
                bottomBar()
                
            }
        }
        .overlay{
            if eventNotFound {
                PageNotFoundView()
            } else if showConfirmLocationError {
                VStack{
                    if eventVM.distance < 1 {
                        Text("\(eventVM.distance * 1000)m/50m")
                            .font(.body)
                            .fontWeight(.bold)
                            .opacity(0.5)
                    } else {
                        Text("\(eventVM.distance)km/50m")
                            .font(.body)
                            .fontWeight(.bold)
                            .opacity(0.5)
                    }
                    
                    Text("Out of range.")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                }
                .padding()
                .background(.bar)
                .cornerRadius(10)
            } else if post.blockedForCurrentUser {
                PageIsNotAvailableView()
            } else if hideEvent {
                HiddenPageView {
                    Task{
                        if let response = try await APIClient.shared.hideorRevealEvent(postId: post.id, isHide: false) {
                            if response {
                                hideEvent = false
                            }
                        }
                    }
                }
            }
        }
        .onAppear(){
            newDate = post.createdAt
            eventVM.participantsList = []
            eventVM.participantsPage = 0
            Task{
                await fetchAllOnAppear()
            }
            reverseGeocode(coordinate: CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude)){ string in
                print("\(string)")
                
            }
            //            locationCityAndCountry(post.location)
        }
        .onChange(of: chatVM.newNotification){ old, new in
            print("triggered 1")
            if let not = new {
                print("triggered 2")
                eventVM.updateEvent(not: not, post: $post)
            }
        }
        .alert("Change Date", isPresented: $isShowChangeDateAlert) {
            if userViewModel.currentUser?.userRole == .ADMINISTRATOR {
                Button("Yes") {
                    Task{
                        if let response = try await APIClient.shared.changeEventDate(postId: post.id, newDate: newDate){
                            post = response
                        }
                    }
                }
            }
            Button("Cancel") {
                isShowChangeDateAlert = false
            }
        } message: {
            Text("Are you sure you want to change club's date?")
        }
        .sheet(isPresented: $showReportEvent, content: {
            ReportEventView(event: post, isActive: $showReportEvent)
        })
        .sheet(isPresented: $showJoinRequest){
            JoinRequestView(post: $post, isActive: $showJoinRequest, refreshParticipants: {
                Task{
                    do {
                        eventVM.participantsList = []
                        eventVM.participantsPage = 0
                        try await eventVM.fetchUserList(id: post.id)
                    } catch {
                        print("Failed to fetch user list: \(error)")
                    }
                }
            })
        }
        .sheet(isPresented: $showPaymentSheet){
            if post.payment > 0, let max = post.maximumPeople, post.participantsCount >= max {
                VStack(spacing: 15){
                    Text("😤")
                        .font(.custom("image", fixedSize: 120))
                    
                    Text("The event has reached its maximum capacity.\n Check again later...")
                        .font(.body)
                        .foregroundStyle(.gray)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                }
            } else {
                EventCheckoutSheet(post: $post, isActive: $showPaymentSheet, refreshParticipants: {
                    Task{
                        do {
                            eventVM.participantsList = []
                            eventVM.participantsPage = 0
                            try await eventVM.fetchUserList(id: post.id)
                        } catch {
                            print("Failed to fetch user list: \(error)")
                        }
                    }
                })
            }
        }
        .sheet(isPresented: $deleteSheet, content: {
            DeleteEventSheet(){
                Task{
                    try await postsVM.deleteEvent(postId: post.id)
                    if let index = activityVM.activityFeed.firstIndex(where: { $0.post?.id == post.id }) {
                        DispatchQueue.main.async{
                            activityVM.activityFeed.remove(at: index)
                        }
                    }
                }
                DispatchQueue.main.async {
                    if navManager.selectionPath.count >= 1{
                        navManager.selectionPath.removeLast(1)
                    }
                }
            }
            .presentationDetents([.height(190)])
            
        })
        .sheet(isPresented: $eventVM.showAddEvent) {
            EventEditViewController(event: $event, eventStore: store)
        }
        .fullScreenCover(isPresented: $openCreateEvent, content: {
            CreateEventView(prevEvent: post)
        })
        .confirmationDialog("Select Calendar", isPresented: $eventVM.openCalendarSheet) {
            Button("Open in Apple Calendar"){
                if let fromDate = post.fromDate {
                    eventVM.openCalendarSheet = false
                    event = EKEvent(eventStore: store)
                    event?.title = post.title
                    event?.location = post.location.name
                    event?.startDate = fromDate
                    event?.endDate = post.toDate ?? fromDate.addingTimeInterval(3600)
                    event?.notes = post.description ?? "Event in Togeda."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        eventVM.showAddEvent = true
                    }
                }
            }
            if isGoogleCalendarInstalled() {
                Button("Open in Google Calendar"){
                    if let fromDate = post.fromDate {
                        createGoogleCalendarEventWeb(
                            title: post.title,
                            location: post.location.name,
                            startDate: fromDate,
                            endDate: post.toDate ?? fromDate.addingTimeInterval(3600),
                            details: post.description ?? "Event in Togeda."
                        )
                    }
                }
            }
        }
        .confirmationDialog("Select Map", isPresented: $eventVM.openMapSheet) {
            Button("Open in Apple Maps"){
                let url = URL(string: "maps://?saddr=&daddr=\(post.location.latitude),\(post.location.longitude)")
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
            }
            Button("Open in Google Maps"){
                if isGoogleMapsInstalled() {
                    openGoogleMaps(latitude: post.location.latitude, longitude: post.location.longitude)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $isEditing) {
            EditEventView(isActive: $isEditing, post: $post)
        }
        .swipeBack()
        
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
            
            
            
            if let chatRoomID = post.chatRoomId, post.currentUserStatus == .PARTICIPATING {
                Button{
                    Task{
                        print("\(chatRoomID)")
                        do {
                            if let chatroom = try await APIClient.shared.getChat(chatId: chatRoomID) {
                                print("\(chatroom)")
                                //                                    chatVM.chatRoomCheck(chatRoom: chatroom)
                                DispatchQueue.main.async {
                                    navManager.resetMessage = true

                                    navManager.screen = .message
                                    navManager.selectionPath = []
                                    
                                    navManager.selectionPath.append(SelectionPath.userChat(chatroom: chatroom))
                                }
                            } else {
                                print("nil")
                            }
                        } catch {
                            print(error)
                        }
                    }
                } label:{
                    Text("Go To Chat")
                        .font(.footnote)
                        .bold()
                        .frame(height: 35)
                        .padding(.horizontal)
                        .background(.bar)
                        .clipShape(Capsule())
                }
            } else if post.status != .HAS_ENDED, post.currentUserStatus == .PARTICIPATING {
                Button{
                    Task{
                        if let chatRoomId = try await APIClient.shared.createChatForEvent(postId: post.id) {
                            if let chatroom = try await APIClient.shared.getChat(chatId: chatRoomId) {
                                print("\(chatroom)")
                                //                                    chatVM.chatRoomCheck(chatRoom: chatroom)
                                DispatchQueue.main.async {
                                    self.navManager.screen = .message
                                    self.navManager.selectionPath = [.userChat(chatroom: chatroom)]
                                }
                            }
                        }
                    }
                } label:{
                    Text("Create Chat")
                        .font(.footnote)
                        .bold()
                        .frame(height: 35)
                        .padding(.horizontal)
                        .background(.bar)
                        .clipShape(Capsule())
                }
            }
            
            if isOwner {
                if post.status != .HAS_ENDED {
                    Button{
                        isEditing = true
                    } label:{
                        Image(systemName: "pencil")
                            .frame(width: 35, height: 35)
                            .background(.bar)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    }
                } else {
                    Button{
                        openCreateEvent = true
                    } label:{
                        Text("Recreate")
                            .font(.footnote)
                            .bold()
                            .frame(height: 35)
                            .padding(.horizontal)
                            .background(.bar)
                            .clipShape(Capsule())
                    }
                }
            }
            
            Menu{
                ShareLink(item: URL(string:createURLLink(postID: post.id, clubID: nil, userID: nil))!) {
                    Text("Share via")
                }
                
                if isOwner {
                    if post.status == .HAS_ENDED {
                        Button(role: .destructive){
                            deleteSheet = true
                        } label:{
                            HStack(spacing: 20){
                                Image(systemName: "trash")
                                Text("Delete")
                            }
                            .foregroundStyle(.red)
                        }
                        .createEventTabStyle()
                    }
                } else {
                    Button("Report") {
                        showPostOptions = false
                        showReportEvent = true
                    }
                    
                    if post.currentUserStatus != .PARTICIPATING {
                        Button("Hide") {
                            showPostOptions = false
                            Task{
                                if let response = try await APIClient.shared.hideorRevealEvent(postId: post.id, isHide: true) {
                                    if response {
                                        postsVM.feedPosts.removeAll(where: {$0.id == post.id})
                                        activityVM.activityFeed.removeAll(where: {$0.post?.id == post.id})
                                        hideEvent = true
                                    }
                                }
                            }
                        }
                    }
                    
                    if userViewModel.currentUser?.userRole == .ADMINISTRATOR {
                        Menu {
                            Button(){
                                newDate = Date()
                                isShowChangeDateAlert = true
                                
                            } label:{
                                HStack(spacing: 20){
                                    Image(systemName: "arrow.up")
                                    Text("Now")
                                }
                                .foregroundStyle(.red)
                            }
                            
                            Button(){
                                newDate = Calendar.current.date(byAdding: .year, value: 1, to: post.createdAt)!
                                isShowChangeDateAlert = true
                                
                            } label:{
                                HStack(spacing: 20){
                                    Image(systemName: "arrow.up")
                                    Text("1 Year Up")
                                }
                                .foregroundStyle(.red)
                            }
                            
                            Button(){
                                newDate = Calendar.current.date(byAdding: .month, value: 1, to: post.createdAt)!
                                isShowChangeDateAlert = true
                                
                            } label:{
                                HStack(spacing: 20){
                                    Image(systemName: "arrow.up")
                                    Text("1 Month Up")
                                }
                                .foregroundStyle(.red)
                            }
                            
                            Button(){
                                newDate = Calendar.current.date(byAdding: .day, value: 7, to: post.createdAt)!
                                isShowChangeDateAlert = true
                                
                            } label:{
                                HStack(spacing: 20){
                                    Image(systemName: "arrow.up")
                                    Text("1 Week Up")
                                }
                                .foregroundStyle(.red)
                            }
                            
                            
                            Button{
                                newDate = Calendar.current.date(byAdding: .day, value: 1, to: post.createdAt)!
                                isShowChangeDateAlert = true
                                
                            } label:{
                                HStack(spacing: 20){
                                    Image(systemName: "arrow.up")
                                    Text("1 Day Up")
                                }
                                .foregroundStyle(.red)
                            }
                            
                            Button(role: .destructive){
                                newDate = Calendar.current.date(byAdding: .day, value: -1, to: post.createdAt)!
                                isShowChangeDateAlert = true
                                
                            } label:{
                                HStack(spacing: 20){
                                    Image(systemName: "arrow.down")
                                    Text("1 Day Down")
                                }
                                .foregroundStyle(.red)
                            }
                            
                            Button(role: .destructive){
                                newDate = Calendar.current.date(byAdding: .day, value: -7, to: post.createdAt)!
                                isShowChangeDateAlert = true
                                
                            } label:{
                                HStack(spacing: 20){
                                    Image(systemName: "arrow.down")
                                    Text("1 Week Down")
                                }
                                .foregroundStyle(.red)
                            }
                            
                            Button(role: .destructive){
                                newDate = Calendar.current.date(byAdding: .month, value: -1, to: post.createdAt)!
                                isShowChangeDateAlert = true
                                
                            } label:{
                                HStack(spacing: 20){
                                    Image(systemName: "arrow.down")
                                    Text("1 Month Down")
                                }
                                .foregroundStyle(.red)
                            }
                            
                            Button(role: .destructive){
                                newDate = Calendar.current.date(byAdding: .year, value: -1, to: post.createdAt)!
                                isShowChangeDateAlert = true
                                
                            } label:{
                                HStack(spacing: 20){
                                    Image(systemName: "arrow.down")
                                    Text("1 Year Down")
                                }
                                .foregroundStyle(.red)
                            }
                        } label: {
                            HStack(spacing: 20){
                                Image(systemName: "calendar")
                                Text("Change Date")
                            }
                            .foregroundStyle(.red)
                        }
                        
                        Button(role: .destructive){
                            deleteSheet = true
                        } label:{
                            HStack(spacing: 20){
                                Image(systemName: "trash")
                                Text("Delete as Admin")
                            }
                            .foregroundStyle(.red)
                        }
                        .createEventTabStyle()
                    }
                }
                
                
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
    
    @ViewBuilder
    func bottomBar() -> some View {
        VStack{
            Divider()
            
            HStack{
                
                if isOwner {
                    if post.status == .HAS_STARTED {
                        Button {
                            showJoinRequest = true
                        } label: {
                            Text("Stop the Event")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .cornerRadius(10)
                        }
                    }
                    else if post.status == .NOT_STARTED {
                        if post.fromDate != nil {
                            Button {
                                showJoinRequest = true
                            } label: {
                                Text("Delete the Event")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                            }
                        } else {
                            Button {
                                showJoinRequest = true
                            } label: {
                                Text("Start the Event")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    else if post.status == .HAS_ENDED {
                        Text("Ended")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                    }
                    else {
                        Text("Ended")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                    }
                } else {
                    if post.status == .HAS_STARTED {
                        
                        if post.currentUserStatus == .PARTICIPATING && post.needsLocationalConfirmation && post.currentUserArrivalStatus != .ARRIVED {
                            Button {
                                //                                locationManager.requestCurrentLocation()
                                //                                if let location = locationManager.location{
                                if let location = getUserLocationCords(){
                                    let distance = calculateDistance(lat1: location.coordinate.latitude, lon1: location.coordinate.longitude, lat2: post.location.latitude, lon2: post.location.longitude)
                                    eventVM.distance = Int(distance.rounded())
                                    if distance * 1000 <= 50 {
                                        Task{
                                            if let response = try await APIClient.shared.confirmUserLocation(postId: post.id) {
                                                post.currentUserArrivalStatus = .ARRIVED
                                                postsVM.localRefreshEventOnAction(post: post)
                                            }
                                        }
                                    } else {
                                        withAnimation {
                                            showConfirmLocationError = true
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                                            withAnimation {
                                                showConfirmLocationError = false
                                            }
                                        })
                                    }
                                }
                                //                                locationManager.stopLocation()
                            } label: {
                                Text("Confirm Arrival")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                            }
                        } else {
                            Button {
                                showJoinRequest = true
                            } label: {
                                Text("Ongoing")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                            }
                        }
                    } else if post.status == .NOT_STARTED {
                        if post.currentUserStatus == .PARTICIPATING {
                            Button {
                                showJoinRequest = true
                            } label: {
                                Text("Leave")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                            }
                        } else if post.currentUserStatus == .IN_QUEUE {
                            Button {
                                showJoinRequest = true
                            } label: {
                                Text("Waiting")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                            }
                        } else {
                            Button {
                                if post.payment > 0 {
                                    Task{
                                        if let response = try await APIClient.shared.getEvent(postId: post.id){
                                            postsVM.localRefreshEventOnAction(post: response)
                                            post = response
                                            if let max = post.maximumPeople, max <= post.participantsCount{
                                                showJoinRequest = true
                                            } else {
                                                showPaymentSheet = true
                                            }
                                            
                                        } else {
                                            showJoinRequest = true
                                        }
                                    }
                                } else {
                                    showJoinRequest = true
                                }
                            } label: {
                                Text("Join")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color("blackAndWhite"))
                                    .foregroundColor(Color("testColor"))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    else if post.status == .HAS_ENDED {
                        Text("Ended")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                    }
                    else {
                        Button {
                            if post.payment > 0 {
                                showPaymentSheet = true
                            } else {
                                showJoinRequest = true
                            }
                        } label: {
                            Text("Join")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .cornerRadius(10)
                        }
                    }
                }
                
                if post.status != .HAS_ENDED {
                    shareAndSave()
                }
            }
            .padding(.horizontal)
            
        }
        .background(.bar)
    }
    
    @ViewBuilder
    func shareAndSave() -> some View {
        Button {
            postsVM.clickedPost = post
            postsVM.showSharePostSheet = true
        } label: {
            Image(systemName:"paperplane")
                .resizable()
                .scaledToFit()
                .padding()
                .frame(width: 60, height: 60)
                .background(Color("main-secondary-color"))
                .cornerRadius(10)
        }
        
        Button {
            Task{
                if let saved = try await postsVM.saveEvent(postId: post.id) {
                    post.savedByCurrentUser = saved
                }
            }
        } label: {
            Image(systemName: post.savedByCurrentUser ? "bookmark.fill" : "bookmark")
                .resizable()
                .scaledToFit()
                .padding()
                .frame(width: 60, height: 60)
                .background(Color("main-secondary-color"))
                .cornerRadius(10)
        }
    }
    
    var isOwner: Bool {
        if let user = userViewModel.currentUser, user.id == post.owner.id{
            return true
        } else {
            return false
        }
    }
    
    
    func fetchAllOnAppear() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    if let response = try await APIClient.shared.getEvent(postId: post.id){
                        DispatchQueue.main.async {
                            self.post = response
                            self.postsVM.localRefreshEventOnAction(post: post)
                            if let index = self.activityVM.activityFeed.firstIndex(where: { $0.post?.id == post.id }) {
                                self.activityVM.activityFeed[index].post = response
                            }
                            if post.status == .NOT_STARTED {
                                if let from = post.fromDate, from < Date() {
                                    post.status = .HAS_STARTED
                                }
                            }
                        }
                        
                    } else {
                        DispatchQueue.main.async{
                            self.eventNotFound = true
                        }
                    }
                } catch {
                    print(error)
                }
            }
            
            group.addTask {
                do {
                    if let clubId = await post.clubId, let response = try await APIClient.shared.getClub(clubID: clubId){
                        DispatchQueue.main.async {
                            self.club = response
                            self.Init = false
                        }
                        
                    }
                } catch {
                    print(error)
                }
            }
            
            if post.askToJoin {
                group.addTask {
                    do {
                        if let response = try await APIClient.shared.getEventParticipantsWaitingList(
                            postId: post.id,
                            page: 1,
                            size: 1) {
                            DispatchQueue.main.async {
                                self.eventVM.othersCount = response.listCount
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            } else {
                group.addTask {
                    do {
                        if let response = try await APIClient.shared.getEventWaitlist(
                            postId: post.id,
                            page: 1,
                            size: 1) {
                            DispatchQueue.main.async {
                                self.eventVM.othersCount = response.listCount
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            
            
            group.addTask {
                do {
                    try await eventVM.fetchUserList(id: post.id)
                } catch {
                    print(error)
                }
            }
        }
    }
    
}



struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(post: MockPost)
            .environmentObject(PostsViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(WebSocketManager())
            .environmentObject(NavigationManager())
            .environmentObject(ActivityViewModel())
            .environmentObject(LocationManager())
        
    }
}
