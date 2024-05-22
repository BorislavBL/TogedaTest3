//
//  EditGroupView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 4.01.24.
//

import SwiftUI

struct EditGroupView: View {
    @StateObject var editGroupVM = EditGroupViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showTypeSheet = false
    @State private var showInstagramSheet = false
    
    @State private var sheetImage: Image = Image(systemName: "")
    @State private var sheetTitle: String = ""
    @State private var types: [String] = []
    
    @State private var showError: Bool = false
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment: .leading, spacing: 30){
                VStack(alignment: .leading, spacing: 10){
                    Text("Group Photos")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    PhotosGridView(showPhotosPicker: $editGroupVM.showPhotosPicker, selectedImageIndex: $editGroupVM.selectedImageIndex, selectedImages: $editGroupVM.selectedImages)
                }
                
                VStack(alignment: .leading, spacing: 10){
                    Text("Group Info")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    TextField("", text: $editGroupVM.club.title)
                        .placeholder(when: editGroupVM.club.title.isEmpty) {
                            Text("Title")
                                .foregroundColor(.secondary)
                                .bold()
                        }
                        .bold()
                        .createEventTabStyle()
                    
                    if titleError {
                        WarningTextComponent(text: "The field should contain at least 3 letters.")
                    }
                    
                    
                    NavigationLink(destination:  LocationPicker( returnedPlace: $editGroupVM.returnedPlace, isActivePrev: .constant(true))){
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "location.circle.fill")
                                .imageScale(.large)
                            
                            if let location = editGroupVM.location {
                                Text(location.name)
                            } else {
                                Text("Select Location")
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                            
                        }
                        .createEventTabStyle()
                    }
                    
                    NavigationLink {
                        CategoryView(selectedInterests: $editGroupVM.interests, text: "Select at least one tag related to your group", minInterests: 1)
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "circle.grid.2x2")
                                .imageScale(.large)
                            
                            if $editGroupVM.interests.count > 0 {
                                Text(interestsOrder(editGroupVM.interests))
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
                    
                    EditProfileBioView(text: $editGroupVM.description, placeholder: "Description")
                }
                
            }
            .padding()
        }
        .photosPicker(isPresented: $editGroupVM.showPhotosPicker, selection: $editGroupVM.imageselection, matching: .images)
        .fullScreenCover(isPresented: $editGroupVM.showCropView, content: {
            CropPhotoView(selectedImage:editGroupVM.selectedImage, finalImage: $editGroupVM.selectedImages[editGroupVM.selectedImageIndex ?? 0], crop: .custom(CGSize(width: 300, height: 500)))
        })
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
                            showError.toggle()
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
    
    
    var titleError: Bool {
        if editGroupVM.club.title.count < 3 && showError {
            return true
        } else {
            return false
        }
    }
    
    var saveButtonCheck: Bool {
        if editGroupVM.club.title.count < 3 {
            return true
        } else {
            return false
        }
    }
    
}

#Preview {
    EditGroupView()
}
