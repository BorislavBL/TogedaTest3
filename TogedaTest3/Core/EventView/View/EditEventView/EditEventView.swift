//
//  EditEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.01.24.
//

import SwiftUI

struct EditEventView: View {
    var post: Components.Schemas.PostResponseDto
    @StateObject var vm = EditEventViewModel()
    @State private var displayWarnings: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var showLocationView = false
    @State private var showCategoryView = false
    @EnvironmentObject var navManager: NavigationManager
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment: .center, spacing: 30){
                VStack(alignment: .leading, spacing: 10){
                    Text("Event Images")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    
                    EditEventPhotosView(editEventVM: vm)
                    
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
                        WarningTextComponent(text: "Please at least one interest.")
                        
                    }
                    
//                    NavigationLink {
//                        DateView(isDate: $vm.isDate, date: $vm.date, from: $vm.from, to: $vm.to, daySettings: $vm.daySettings, timeSettings: $vm.timeSettings)
//                    } label: {
//                        HStack(alignment: .center, spacing: 10) {
//                            Image(systemName: "calendar")
//                                .imageScale(.large)
//                            
//                            
//                            Text("Date & Time")
//                            
//                            Spacer()
//                            
//                            
//                            Text(vm.isDate ? separateDateAndTime(from:vm.date).date : "Any day")
//                                .foregroundColor(.gray)
//                            
//                            Image(systemName: "chevron.right")
//                                .padding(.trailing, 10)
//                                .foregroundColor(.gray)
//                            
//                        }
//                        .createEventTabStyle()
//                    }
                    
                    VStack(alignment: .leading, spacing: 20){
                        Button{
                            vm.showTimeSettings.toggle()
                        } label: {
                            HStack(alignment: .center, spacing: 10) {
                                Image(systemName: "calendar")
                                    .imageScale(.large)
                                
                                Text("Date & Time")
                                
                                Spacer()
                                
                                Text(vm.isDate ? separateDateAndTime(from: vm.from).date : "Any day")
                                    .foregroundColor(.gray)
                                
                                Image(systemName: vm.showTimeSettings ? "chevron.down" : "chevron.right")
                                    .padding(.trailing, 10)
                                    .foregroundColor(.gray)
                                
                            }
                            
                        }
                        
                        if vm.showTimeSettings {
                            Picker("Choose Date", selection: $vm.dateTimeSettings){
                                Text("Exact").tag(0)
                                Text("Range").tag(1)
                                Text("Anytime").tag(2)
                            }
                            .pickerStyle(.segmented)
                            
                            if vm.dateTimeSettings != 2 {
                                DatePicker("From", selection: $vm.from, in: Date().addingTimeInterval(900)..., displayedComponents: [.date, .hourAndMinute])
                                    .fontWeight(.semibold)
                                
                                if vm.dateTimeSettings == 1 {
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
                                
                            }
                            
                        }
                    }
                    .createEventTabStyle()
                    
                    
                }
            }
            .padding()
        }
        .onAppear {
            if vm.isInit {
                vm.fetchPostData(post: post)
                vm.isInit = false
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Edit Profile")
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
        .onAppear{
            if vm.isInit {
                vm.fetchPostData(post: post)
                vm.isInit = false
            }
        }
    }
    
    func save() {
        Task {
            do{
                if await vm.imageCheckAndMerge(){
                    if vm.editPost != vm.initialPost {
                        let data = try await APIClient.shared.editEvent(postId: vm.editPost.id, editPost: vm.convertToPathcPost(post: vm.editPost))
                        print("Success: \(data)")
                        
                        //fetch current post here
                        
                        dismiss()
                    } else {
                        print("No changes")
                        dismiss()
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
        if vm.selectedImages.allSatisfy({ $0 == nil }) && displayWarnings{
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
    
    var saveButtonCheck: Bool {
        if vm.editPost.title.count >= 5, !vm.editPost.title.isEmpty, vm.editPost.location.name != "Unknown Location", vm.selectedImages.contains(where: { $0 != nil }),vm.selectedInterests.count > 0 {
            return true
        } else {
            return false
        }
    }
    
}

#Preview {
    EditEventView(post: MockPost)
        .environmentObject(NavigationManager())
}
