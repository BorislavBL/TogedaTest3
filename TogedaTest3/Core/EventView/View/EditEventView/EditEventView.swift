//
//  EditEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.01.24.
//

import SwiftUI

struct EditEventView: View {
    var post: Post = .MOCK_POSTS[0]
    @StateObject var vm = EditEventViewModel()
    @State private var displayWarnings: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment: .center, spacing: 30){
                VStack(alignment: .leading, spacing: 10){
                    Text("Event Images")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    
                    PhotosGridView(showPhotosPicker: $vm.showPhotosPicker, selectedImageIndex: $vm.selectedImageIndex, selectedImages: $vm.selectedImages)
                    
                    if noPhotos {
                        WarningTextComponent(text: "Please add photos.")
                        
                    }
                }
                
                VStack(alignment: .leading, spacing: 10){
                    Text("Profile Info")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    TextField("", text: $vm.title)
                        .placeholder(when: vm.title.isEmpty) {
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
                    
                    NavigationLink {
                        LocationPicker(returnedPlace: $vm.returnedPlace)
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "mappin.circle")
                                .imageScale(.large)
                            
                            
                            Text("Location")
                            
                            Spacer()
                            
                            if let location = vm.location{
                                
                                Text(location.name)
                                    .foregroundColor(.gray)
                            } else {
                                Text("Select")
                                    .foregroundColor(.gray)
                            }
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                            
                        }
                        .createEventTabStyle()
                    }
                    
                    if noLocation {
                        WarningTextComponent(text: "Please select a location.")
                        
                    }
                    
                    NavigationLink {
                        CategoryView(selectedInterests: $vm.selectedInterests, text: "Select at least one tag related to your event", minInterests: 0)
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
                    
                    NavigationLink {
                        DateView(isDate: $vm.isDate, date: $vm.date, from: $vm.from, to: $vm.to, daySettings: $vm.daySettings, timeSettings: $vm.timeSettings)
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "calendar")
                                .imageScale(.large)
                            
                            
                            Text("Date & Time")
                            
                            Spacer()
                            
                            
                            Text(vm.isDate ? separateDateAndTime(from:vm.date).date : "Any day")
                                .foregroundColor(.gray)
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                        }
                        .createEventTabStyle()
                    }
                    
                    VStack(alignment: .leading, spacing: 20){
                        
                        Button {
                            vm.showParticipants.toggle()
                        } label: {
                            
                            HStack(alignment: .center, spacing: 10) {
                                Image(systemName: "person.2.circle")
                                    .imageScale(.large)
                                
                                
                                Text("Participants")
                                
                                Spacer()
                                
                                if let participant = vm.participants{
                                    Text(participant > 0 ? "\(participant)" : "No Limit")
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
                                
                                TextField("Max", value: $vm.participants, format:.number)
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
        .scrollIndicators(.hidden)
        .navigationTitle("Edit Profile")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if saveButtonCheck{
                    Button {
                        dismiss()
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
        .onAppear{
            vm.fetchPostData(post: post)
        }
    }
    
    var titleEmpty: Bool {
        if vm.title.isEmpty && displayWarnings {
            return true
        } else {
            return false
        }
    }
    
    var titleChartLimit: Bool {
        if !vm.title.isEmpty && displayWarnings && vm.title.count < 5 {
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
        if vm.returnedPlace.name == "Unknown Location" && displayWarnings {
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
        if vm.title.count >= 5, !vm.title.isEmpty, vm.returnedPlace.name != "Unknown Location", vm.selectedImages.contains(where: { $0 != nil }),vm.selectedInterests.count > 0 {
            return true
        } else {
            return false
        }
    }
    
}

#Preview {
    EditEventView()
}
