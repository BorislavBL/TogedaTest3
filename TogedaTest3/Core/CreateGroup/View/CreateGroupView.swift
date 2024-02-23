//
//  CreateGroupView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 28.12.23.
//

import SwiftUI

struct CreateGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var createGroupVM = CreateGroupViewModel()
    @State private var showExitSheet: Bool = false
    @State private var displayWarnings: Bool = false
    
    @State private var showDescription: Bool = false
    @State private var showPhotos: Bool = false
    @State private var showLocation: Bool = false
    @State private var showInterests: Bool = false
    @State private var showAcessibility: Bool = false
    @State private var showPermission: Bool = false
    
    let placeholder = "Provide a brief overview of your group. What is the main focus or interest? Describe the typical activities, meetings, or events you organize. Highlight any unique aspects or notable achievements."
    
    var body: some View {
        NavigationStack{
            VStack{
                ScrollView{
                    VStack(alignment: .leading){
                        Text("Title:")
                            .foregroundStyle(.tint)
                        TextField("What group would you like to make", text: $createGroupVM.title, axis: .vertical)
                            .font(.headline)
                            .fontWeight(.bold)
                            .onChange(of: createGroupVM.title) { oldValue, newValue in
                                if createGroupVM.title.count > 70 {
                                    createGroupVM.title = String(createGroupVM.title.prefix(70))
                                }
                            }
                    }
                    .createEventTabStyle()
                    .padding(.top)
                    
                    if titleEmpty {
                        WarningTextComponent(text: "Please write a title.")
                    } else if titleChartLimit {
                        WarningTextComponent(text: "The title has to be more than 5 characters long.")
                    }
                    
                    //                VStack(alignment: .leading){
                    //                    Text("Description:")
                    //                        .foregroundStyle(.tint)
                    //                    TextField(placeholder, text: $description, axis: .vertical)
                    //                        .lineLimit(5, reservesSpace: true)
                    //                        .onChange(of: description) { oldValue, newValue in
                    //                            if description.count > 500 {
                    //                                description = String(description.prefix(500))
                    //                            }
                    //                        }
                    //
                    //                    HStack{
                    //                        Spacer()
                    //                        Text("\(500 - description.count)")
                    //                            .fontWeight(.semibold)
                    //                            .foregroundStyle(.gray)
                    //                    }
                    //                }
                    //                .createEventTabStyle()
                    
                    Button {
                        showDescription = true
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "square.and.pencil")
                                .imageScale(.large)
                            
                            
                            Text("Description")
                            
                            Spacer()
                            
                            Text(createGroupVM.description)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                        }
                        .createEventTabStyle()
                    }
                    
                    Button {
                        showPhotos = true
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "photo")
                                .foregroundStyle(.tint)
                            Text("Photos")
                                .foregroundStyle(.tint)
                            Spacer()
                            
                            if createGroupVM.selectedImages.contains(where: {$0 != nil}) {
                                Text("Selected")
                                    .foregroundColor(.gray)
                            } else {
                                Text("Select")
                                    .foregroundStyle(.gray)
                            }
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundStyle(.gray)
                            
                            
                        }
                        .createEventTabStyle()
                    }
                    
                    if noPhotos {
                        WarningTextComponent(text: "Please add photos.")
                        
                    }
                    
                    Button {
                        showLocation = true
                    }label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "mappin.circle")
                                .imageScale(.large)
                            
                            
                            Text("Location")
                            
                            Spacer()
                            
                            if let location = createGroupVM.location{
                                
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
                    
                    Button {
                        showInterests = true
                    } label:{
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "circle.grid.2x2")
                                .imageScale(.large)
                            
                            if createGroupVM.selectedInterests.count > 0 {
                                Text(interestsOrder(createGroupVM.selectedInterests))
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
                    
                    Text("Aditional Options")
                        .font(.callout)
                        .foregroundStyle(.gray)
                        .fontWeight(.bold)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                        .padding(.horizontal, 8)
                    
                    Button {
                        showAcessibility = true
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "eye.circle")
                                .imageScale(.large)
                            
                            
                            Text("Accessibility")
                            
                            Spacer()
                            
                            Text(createGroupVM.selectedVisability)
                                .foregroundColor(.gray)
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                            
                        }
                        .createEventTabStyle()
                    }
                    
                    Button {
                        showPermission = true
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "lock")
                                .imageScale(.large)
                            
                            Text("Permissions")
                            
                            Spacer()
                            
                            Text(createGroupVM.selectedPermission.value)
                                .foregroundColor(.gray)
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                            
                        }
                        .createEventTabStyle()
                    }
                }
                .padding(.horizontal)
                .scrollIndicators(.hidden)
                .navigationBarBackButtonHidden(true)

                if allRequirenments {
                    Button{
                        Task{
                            do{
                                if await createGroupVM.saveImages() {
                                    let createClub = createGroupVM.createClub()
                                    print(createClub)
                                    try await ClubService.shared.createClub(clubData: createClub)
                                    dismiss()
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
                    } label: {
                        Text("Create")
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("blackAndWhite"))
                            .foregroundColor(Color("testColor"))
                            .cornerRadius(10)
                            .fontWeight(.semibold)
                    }
                    .padding()
                } else {
                    Text("Create")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(.gray)
                        .foregroundColor(Color("testColor"))
                        .cornerRadius(10)
                        .fontWeight(.semibold)
                        .padding()
                        .onTapGesture {
                            displayWarnings.toggle()
                        }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle("Create Gorup")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:Button(action: {showExitSheet.toggle()}) {
                Image(systemName: "xmark")
                    .imageScale(.medium)
                    .padding(.all, 8)
                    .background(Color("secondaryColor"))
                    .clipShape(Circle())
            }
            )
            .navigationDestination(isPresented: $showDescription) {
                DescriptionView(description: $createGroupVM.description, placeholder: placeholder)
            }
            .navigationDestination(isPresented: $showPhotos) {
                NormalPhotoPickerView(createGroupVM: createGroupVM, message: "Select images related to the group activities.")
            }
            .navigationDestination(isPresented: $showLocation) {
                LocationPicker(returnedPlace: $createGroupVM.returnedPlace)
            }
            .navigationDestination(isPresented: $showInterests) {
                CategoryView(selectedInterests: $createGroupVM.selectedInterests, text: "Select at least one tag related to your group", minInterests: 0)
            }
            .navigationDestination(isPresented: $showAcessibility) {
                GroupAccessibilityView(selectedVisability: $createGroupVM.selectedVisability, askToJoin: $createGroupVM.askToJoin)
            }
            .navigationDestination(isPresented: $showPermission) {
                GroupPermissionsView(selectedPermission: $createGroupVM.selectedPermission)
            }
        }
        .sheet(isPresented: $showExitSheet, content: {
            onCloseTab()
        })
        
    }
    
    
    func onCloseTab() -> some View {
        VStack(spacing: 30){
            Text("On Exit all of the data will be lost.")
                .font(.headline)
                .fontWeight(.bold)
            
            Button{
                dismiss()
            } label:{
                Text("Exit")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(.red)
                    .cornerRadius(10)
            }
        }
        .padding()
        .presentationDetents([.fraction(0.2)])
    }
    
    var titleEmpty: Bool {
        if createGroupVM.title.isEmpty && displayWarnings {
            return true
        } else {
            return false
        }
    }
    
    var titleChartLimit: Bool {
        if !createGroupVM.title.isEmpty && displayWarnings && createGroupVM.title.count < 5 {
            return true
        } else {
            return false
        }
    }
    
    var noPhotos: Bool {
        if createGroupVM.selectedImages.allSatisfy({ $0 == nil }) && displayWarnings{
            return true
        } else {
            return false
        }
    }
    
    var noLocation: Bool {
        if createGroupVM.returnedPlace.name == "Unknown Location" && displayWarnings {
            return true
        } else {
            return false
        }
    }
    
    var noTag: Bool {
        if createGroupVM.selectedInterests.count == 0 && displayWarnings {
            return true
        } else {
            return false
        }
    }
    
    var allRequirenments: Bool {
        if createGroupVM.title.count >= 5, !createGroupVM.title.isEmpty, createGroupVM.returnedPlace.name != "Unknown Location", createGroupVM.selectedImages.contains(where: { $0 != nil }), createGroupVM.selectedInterests.count > 0 {
            return true
        } else {
            return false
        }
    }
}

#Preview {
    CreateGroupView()
        .environmentObject(LocationManager())
}
