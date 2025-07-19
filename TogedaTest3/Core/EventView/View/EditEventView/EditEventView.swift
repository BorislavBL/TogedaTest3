//
//  EditEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.01.24.
//

import SwiftUI

struct EditEventView: View {
    @Binding var isActive: Bool
    @Binding var post: Components.Schemas.PostResponseDto
    @StateObject var vm = EditEventViewModel()
    @State private var displayWarnings: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var showLocationView = false
    @State private var showCategoryView = false
    @State private var showAccessibility = false
    @EnvironmentObject var navManager: NavigationManager
    @EnvironmentObject var postsVM: PostsViewModel
    @EnvironmentObject var activityVM: ActivityViewModel
    @State var deleteSheet: Bool = false
    @StateObject var photoPickerVM = PhotoPickerViewModel(s3BucketName: .post, mode: .edit)
    @State var isLoading = false
    @State private var errorMessage: String?
    @State private var deleteError: Bool = false
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var chatManager: WebSocketManager


    
    var body: some View {
        ScrollView{
            LazyVStack(alignment: .center, spacing: 30){
                
                if let errorMessage = errorMessage {
                    WarningTextComponent(text: errorMessage)
                }
                
                VStack(alignment: .leading, spacing: 10){
                    Text("Event Images")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    
//                    EditEventPhotosView(editEventVM: vm)
                    PhotosGridView(images: $vm.editPost.images, vm: photoPickerVM)
                    
                    if noPhotos {
                        WarningTextComponent(text: "Please add photos.")
                        
                    }
                }
                
                VStack(alignment: .leading, spacing: 10){
                    Text("Event Info")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    TextField("", text: $vm.editPost.title)
                        .placeholder(when: vm.editPost.title.isEmpty) {
                            Text("Title")
                                .foregroundColor(.secondary)
                                .bold()
                        }
                        .bold()
                        .createEventTabStyle()
                    
                    if titleEmpty {
                        WarningTextComponent(text: "Please write a title.")
                    } else if titleChartLimit {
                        WarningTextComponent(text: "The title has to be more than 5 characters long.")
                    }
                    
                    EditProfileBioView(text: $vm.description, placeholder: "Description")
                    

//                    Toggle(isOn: $vm.editPost.askToJoin) {
//                        Text("Ask for permission")
//                            .fontWeight(.semibold)
//                    }
//                    .createEventTabStyle()

                    
                    Button {
                        showLocationView = true
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "mappin.circle")
                                .imageScale(.large)
                            
                            
                            Text("Location")
                            
                            Spacer()
                            
                            
                            Text(vm.editPost.location.name)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                            
                        }
                        .createEventTabStyle()
                    }
                    
                    
                    if noLocation {
                        WarningTextComponent(text: "Please select a location.")
                        
                    }
                    
                    Button {
                        showCategoryView = true
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "circle.grid.2x2")
                                .imageScale(.large)
                            
                            if $vm.selectedInterests.count > 0 {
                                Text(interestsOrder(vm.selectedInterests))
                                    .lineLimit(1)
                                Spacer()
                            } else {
                                Text("Interests")
                                Spacer()
                                Text("Select")
                                    .foregroundColor(.gray)
                            }
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                            
                        }
                        .createEventTabStyle()
                    }
                    
                    if noTag {
                        WarningTextComponent(text: "Please select at least one interest.")
                        
                    }
                    
                    Button{
                        showAccessibility = true
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "eye.circle")
                                .imageScale(.large)
                            
                            
                            Text("Accessibility")
                            
                            Spacer()
                            
                            
                            Text(vm.editPost.accessibility.rawValue.capitalized)
                                .foregroundColor(.gray)
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                        }
                        .createEventTabStyle()
                    }
                    if post.status != .HAS_STARTED {
                        VStack(alignment: .leading, spacing: 20){
                            Button{
                                vm.showTimeSettings.toggle()
                            } label: {
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "calendar")
                                        .imageScale(.large)
                                    
                                    Text("Date & Time")
                                    
                                    Spacer()
                                    
                                    if vm.dateTimeSettings == 1 {
                                        Text(separateDateAndTime(from: vm.from).date)
                                            .foregroundColor(.gray)
                                    } else if vm.dateTimeSettings == 2 {
                                        Text("\(separateDateAndTime(from: vm.from).date) - \(separateDateAndTime(from: vm.to).date)")
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    } else {
                                        Text("Anyday")
                                            .foregroundColor(.gray)
                                    }
                                    
                                    
                                    Image(systemName: vm.showTimeSettings ? "chevron.down" : "chevron.right")
                                        .padding(.trailing, 10)
                                        .foregroundColor(.gray)
                                    
                                }
                                
                            }
                            
                            if vm.showTimeSettings {
                                Picker("Choose Date", selection: $vm.dateTimeSettings){
                                    Text("Anytime").tag(0)
                                    Text("Exact").tag(1)
                                    Text("Range").tag(2)
                                    
                                }
                                .pickerStyle(.segmented)
                                
                                if vm.dateTimeSettings != 0 {
                                    DatePicker("From", selection: $vm.from, in: Date().addingTimeInterval(900)..., displayedComponents: [.date, .hourAndMinute])
                                        .fontWeight(.semibold)
                                    
                                    if vm.dateTimeSettings == 2 {
                                        DatePicker("To", selection: $vm.to, in: vm.from.addingTimeInterval(600)..., displayedComponents: [.date, .hourAndMinute])
                                            .fontWeight(.semibold)
                                    }
                                } else {
                                    HStack {
                                        Text("The event won't have a specific timeframe.")
                                            .fontWeight(.medium)
                                            .padding()
                                    }
                                }
                                
                                
                            }
                        }
                        .createEventTabStyle()
                        
                        
                        VStack(alignment: .leading, spacing: 20){
                            
                            Button {
                                vm.showParticipants.toggle()
                            } label: {
                                
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "person.2.circle")
                                        .imageScale(.large)
                                    
                                    
                                    Text("Participants")
                                    
                                    Spacer()
                                    if let max = vm.editPost.maximumPeople {
                                        Text("\(max)")
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    } else {
                                        Text("No Limit")
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Image(systemName: vm.showParticipants ? "chevron.down" : "chevron.right")
                                        .padding(.trailing, 10)
                                        .foregroundColor(.gray)
                                    
                                }
                                
                            }
                            if vm.showParticipants {
                                HStack(alignment: .center, spacing: 10) {
                                    Text("The number of participants")
                                    
                                    Spacer()
                                    
                                    TextField("Max", value: $vm.editPost.maximumPeople, format:.number)
                                        .foregroundColor(.gray)
                                        .frame(width: 70)
                                        .textFieldStyle(.roundedBorder)
                                        .keyboardType(.numberPad)
                                        .onChange(of: vm.editPost.maximumPeople) { old, new in
                                            if let number = vm.editPost.maximumPeople {
                                                if number > 1000000 {
                                                    vm.editPost.maximumPeople = old
                                                }
                                            }
                                        }
                                    
                                }
                                
                            }
                        }
                        .createEventTabStyle()
                    }
                    
                    if post.payment > 0, post.participantsCount > 1  {
                        if deleteError{
                            WarningTextComponent(text: "Sorry you can't just delete a paid event with participants in it. If you want to cancel the activity discuss it with your participants via the chat.")
                        }
                        HStack(spacing: 20){
                            Image(systemName: "trash")
                            Text("Delete")
                        }
                        .createEventTabStyle()
                        .onTapGesture {
                            deleteError.toggle()
                        }
                    } else {
                        Button{
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
                    
                }
            }
            .padding()
        }
        .swipeBack()
        .overlay {
            if isLoading {
                LoadingScreenView(isVisible: $isLoading)
            }
        }
        .onAppear {
            if vm.isInit {
                vm.fetchPostData(post: post)
                vm.isInit = false
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
                    if let chatRoomId = post.chatRoomId {
                        chatManager.allChatRooms.removeAll(where: {$0.id == chatRoomId})
                    }
                }
                DispatchQueue.main.async {
                    isActive = false
                    if navManager.selectionPath.count >= 1{
                        navManager.selectionPath.removeLast(1)
                    }
                    userVM.removePost(post: post)
                }
            }
            .presentationDetents([.height(190)])
                
        })
        .toolbar{
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardToolbarItems()
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Edit Event")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if saveButtonCheck{
                    Button {
                        save()
                    } label: {
                        Text("Save")
                            .foregroundStyle(.blue)
                            .bold()
                    }
                } else {
                    Text("Save")
                        .foregroundStyle(.blue.opacity(0.5))
                        .bold()
                        .onTapGesture {
                            displayWarnings.toggle()
                        }
                }
                
                
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.blue)
                    
                }
                
            }
        }
        .navigationDestination(isPresented: $showLocationView, destination: {
            LocationPicker(returnedPlace: $vm.returnedPlace, isActivePrev: $showLocationView)
        })
        .navigationDestination(isPresented: $showCategoryView, destination: {
            CategoryView(selectedInterests: $vm.selectedInterests, text: "Select at least one tag related to your event", minInterests: 0)
        })
        .navigationDestination(isPresented: $showAccessibility, destination: {
            EditAccessibilityView(selectedVisability: $vm.editPost.accessibility)
        })
        .onAppear{
            if vm.isInit {
                vm.fetchPostData(post: post)
                vm.isInit = false
            }
        }
    }
    
    func save() {
        errorMessage = nil
        Task {
            do{
                if await photoPickerVM.imageCheckAndMerge(images: $vm.editPost.images){
                    withAnimation{
                        isLoading = true
                    }
                    vm.setDate()
                    if vm.editPost != vm.initialPost {
                        vm.editPost.title = trimAndLimitWhitespace(vm.editPost.title)
                        if let description = vm.editPost.description{
                            vm.editPost.description = trimAndLimitWhitespace(description)
                        }

                        try await APIClient.shared.editEvent(postId: vm.editPost.id, editPost: vm.convertToPatchPost(post: vm.editPost)) { response, error in
                            if let _ = response {
                                Task {
                                    if let response = try await APIClient.shared.getEvent(postId: post.id) {
                                        postsVM.localRefreshEventOnAction(post: response)
                                        activityVM.localRefreshEventOnAction(post: response)
                                    }
                                }
                                DispatchQueue.main.async {
                                    self.post = vm.editPost
                                    withAnimation{
                                        self.isLoading = false
                                    }
                                    dismiss()
                                }

                            } else if let error = error {
                                DispatchQueue.main.async {
                                    withAnimation{
                                        self.isLoading = false
                                    }
                                    
                                    self.errorMessage = error
                                }
                            }
                        }

                    } else {
                        print("No changes")
                        dismiss()
                        withAnimation{
                            isLoading = false
                        }
                    }
                } else {
                    print("No images")
                }
            } catch GeneralError.badRequest(details: let details){
                print(details)
            } catch GeneralError.invalidURL {
                print("Invalid URL")
            } catch GeneralError.serverError(let statusCode, let details) {
                print("Status: \(statusCode) \n \(details)")
            } catch {
                print("Error message:", error)
            }
            
        }
    }
    
    
    var titleEmpty: Bool {
        if vm.editPost.title.isEmpty && displayWarnings {
            return true
        } else {
            return false
        }
    }
    
    var titleChartLimit: Bool {
        if !vm.editPost.title.isEmpty && displayWarnings && vm.editPost.title.count < 5 {
            return true
        } else {
            return false
        }
    }
    
    var noPhotos: Bool {
        if vm.editPost.images.count == 0 && photoPickerVM.selectedImages.allSatisfy({ $0 == nil }) && displayWarnings{
            return true
        } else {
            return false
        }
    }
    
    var noLocation: Bool {
        if vm.editPost.location.name == "Unknown Location" && displayWarnings {
            return true
        } else {
            return false
        }
    }
    
    var noTag: Bool {
        if vm.selectedInterests.count == 0 && displayWarnings {
            return true
        } else {
            return false
        }
    }
    
    var changedTime: Bool {
        if let from = vm.initialPost.fromDate {
            if from != vm.from {
                return true
            } else if let to = vm.initialPost.toDate, to != vm.to {
                return true
            }
        }
        
        return false
    }
    
    var saveButtonCheck: Bool {
        if vm.editPost.title.count >= 5, !vm.editPost.title.isEmpty, vm.editPost.location.name != "Unknown Location", (photoPickerVM.selectedImages.contains(where: { $0 != nil }) || vm.editPost.images.count > 0), vm.selectedInterests.count > 0, (vm.editPost != vm.initialPost || photoPickerVM.imageIsSelected()) || changedTime{
            return true
        } else {
            return false
        }
    }
    
}

#Preview {
    EditEventView(isActive: .constant(true), post: .constant(MockPost))
        .environmentObject(NavigationManager())
        .environmentObject(PostsViewModel())
        .environmentObject(ActivityViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(WebSocketManager())

}
