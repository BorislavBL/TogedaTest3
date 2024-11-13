//
//  EditGroupView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 4.01.24.
//

import SwiftUI

struct EditClubView: View {
    @Binding var isActive: Bool
    @Binding var club: Components.Schemas.ClubDto
    @StateObject var editGroupVM = EditClubViewModel()
    @StateObject var photoPickerVM = PhotoPickerViewModel(s3BucketName: .club, mode: .edit)
    @EnvironmentObject var clubsVM: ClubsViewModel
    @EnvironmentObject var activityVM: ActivityViewModel

    @Environment(\.dismiss) var dismiss
    @State private var showTypeSheet = false
    @State private var showInstagramSheet = false
    
    @State private var sheetImage: Image = Image(systemName: "")
    @State private var sheetTitle: String = ""
    @State private var types: [String] = []
    
    @State private var displayWarnings: Bool = false
    
    @State private var showLocation: Bool = false
    @State private var showInterests: Bool = false
    @State private var showAcessibility: Bool = false
    @State private var showPermission: Bool = false
    
    @State var deleteSheet: Bool = false
    
    @EnvironmentObject var navManager: NavigationManager
    @State var isLoading = false
    
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment: .leading, spacing: 30){
                
                if let errorMessage = errorMessage {
                    WarningTextComponent(text: errorMessage)
                }
                
                VStack(alignment: .leading, spacing: 10){
                    Text("Club Photos")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    PhotosGridView(images: $editGroupVM.editClub.images, vm: photoPickerVM)
                }
                
                if noPhotos {
                    WarningTextComponent(text: "Add at least one Photo.")
                }
                
                VStack(alignment: .leading, spacing: 10){
                    Text("Club Info")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    TextField("", text: $editGroupVM.editClub.title)
                        .placeholder(when: editGroupVM.editClub.title.isEmpty) {
                            Text("Title")
                                .foregroundColor(.secondary)
                                .bold()
                        }
                        .bold()
                        .createEventTabStyle()
                    
                    if titleEmpty {
                        WarningTextComponent(text: "The title can not be empty.")
                    } else if titleChartLimit {
                        WarningTextComponent(text: "The field should contain at least 5 letters.")
                    }
                    
                    
                    Button {
                        showLocation = true
                    }label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "location.circle.fill")
                                .imageScale(.large)
                            

                            Text(editGroupVM.editClub.location.name)
                                .lineLimit(1)

                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                            
                        }
                        .createEventTabStyle()
                    }
                    
                    if noLocation {
                        WarningTextComponent(text: "Select a location.")
                    }
                    
                    NavigationLink {
                        CategoryView(selectedInterests: $editGroupVM.selectedInterests, text: "Select at least one tag related to your club", minInterests: 0)
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "circle.grid.2x2")
                                .imageScale(.large)
                            
                            if $editGroupVM.selectedInterests.count > 0 {
                                Text(interestsOrder(editGroupVM.selectedInterests))
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
                        WarningTextComponent(text: "Select at leats one interests.")
                    }
                    
                    EditProfileBioView(text: $editGroupVM.description, placeholder: "Description")
                    
                    Button {
                        showAcessibility = true
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "eye.circle")
                                .imageScale(.large)
                            
                            
                            Text("Accessibility")
                            
                            Spacer()
                            
                            Text(editGroupVM.editClub.accessibility.rawValue.capitalized)
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
                            
                            Text(editGroupVM.editClub.permissions.rawValue.capitalized)
                                .foregroundColor(.gray)
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                            
                        }
                        .createEventTabStyle()
                    }
                    
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
            .padding()
        }
        .swipeBack()
        .overlay {
            if isLoading {
                LoadingScreenView(isVisible: $isLoading)
            }
        }
        .navigationDestination(isPresented: $showLocation) {
            LocationPicker(returnedPlace: $editGroupVM.returnedPlace, isActivePrev: $showLocation)
        }
        .navigationDestination(isPresented: $showInterests) {
            CategoryView(selectedInterests: $editGroupVM.selectedInterests, text: "Select at least one tag related to your club", minInterests: 0)
        }
        .navigationDestination(isPresented: $showAcessibility) {
            GroupAccessibilityView(selectedVisability: $editGroupVM.selectedVisability, askToJoin: $editGroupVM.editClub.askToJoin)
        }
        .navigationDestination(isPresented: $showPermission) {
            GroupPermissionsView(selectedPermission: $editGroupVM.selectedPermission)
        }
        .onAppear{
            if editGroupVM.isInit {
                editGroupVM.fetchClubData(club: club)
                editGroupVM.isInit = false
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Edit Club")
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $deleteSheet, content: {
            onDeleteSheet()
                .presentationDetents([.height(190)])
                
        })
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
        
    }
    
    
    func onDeleteSheet() -> some View {
        VStack(spacing: 30){
            Text("All of the information including the chat will be deleted!")
                .multilineTextAlignment(.leading)
                .font(.headline)
                .fontWeight(.bold)
            
            Button{
                Task{
                    try await clubsVM.deleteClub(clubId: club.id)
                    if let index = activityVM.activityFeed.firstIndex(where: {$0.club?.id == club.id}) {
                        activityVM.activityFeed.remove(at: index)
                    }
                    DispatchQueue.main.async {
                        isActive = false
                        navManager.selectionPath.removeLast(1)
                    }
                    
                }

            } label:{
                Text("Delete")
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
    
    func save() {
        Task {
            errorMessage = nil
            do{
                if await photoPickerVM.imageCheckAndMerge(images: $editGroupVM.editClub.images){
                    withAnimation{
                        isLoading = true
                    }
                    if editGroupVM.editClub != editGroupVM.initialClub {
                        editGroupVM.editClub.title = trimAndLimitWhitespace( editGroupVM.editClub.title)
                        if let description = editGroupVM.editClub.description {
                            editGroupVM.editClub.description = trimAndLimitWhitespace(description)
                        }
                        try await APIClient.shared.editClub(clubID: club.id, body: editGroupVM.convertToPatchClub(), completion: {
                            response, error in
                            if let response = response, response {
                                Task{
                                    if let response = try await APIClient.shared.getClub(clubID: club.id) {
                                        if let index = clubsVM.feedClubs.firstIndex(where: { $0.id == club.id }) {
                                            DispatchQueue.main.async{
                                                clubsVM.feedClubs[index] = response
                                            }
                                        }
                                        
                                        if let index = activityVM.activityFeed.firstIndex(where: { $0.club?.id == club.id }) {
                                            DispatchQueue.main.async{
                                                activityVM.activityFeed[index].club = response
                                            }
                                        }
                                    }
                                }
                                DispatchQueue.main.async {
                                    self.club = editGroupVM.editClub
                                    
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
                            
                        })
                        
                    } else {
                        print("No changes")
                        withAnimation{
                            isLoading = false
                        }
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
        if editGroupVM.editClub.title.isEmpty && displayWarnings {
            return true
        } else {
            return false
        }
    }
    
    var titleChartLimit: Bool {
        if !editGroupVM.editClub.title.isEmpty && displayWarnings && editGroupVM.editClub.title.count < 5 {
            return true
        } else {
            return false
        }
    }
    
    var noPhotos: Bool {
        if editGroupVM.editClub.images.count == 0 && photoPickerVM.selectedImages.allSatisfy({ $0 == nil }) && displayWarnings{
            return true
        } else {
            return false
        }
    }
    
    var noLocation: Bool {
        if editGroupVM.editClub.location.name == "Unknown Location" && displayWarnings {
            return true
        } else {
            return false
        }
    }
    
    var noTag: Bool {
        if editGroupVM.selectedInterests.count == 0 && displayWarnings {
            return true
        } else {
            return false
        }
    }
    
    var saveButtonCheck: Bool {
        if editGroupVM.editClub.title.count >= 5, !editGroupVM.editClub.title.isEmpty, editGroupVM.editClub.location.name != "Unknown Location", (photoPickerVM.selectedImages.contains(where: { $0 != nil }) || editGroupVM.editClub.images.count > 0), editGroupVM.selectedInterests.count > 0, (editGroupVM.editClub != editGroupVM.initialClub || photoPickerVM.imageIsSelected()) {
            return true
        } else {
            return false
        }
    }
    
}

#Preview {
    EditClubView(isActive: .constant(true), club: .constant(MockClub))
        .environmentObject(NavigationManager())
        .environmentObject(ActivityViewModel())
        .environmentObject(ClubsViewModel())
}
