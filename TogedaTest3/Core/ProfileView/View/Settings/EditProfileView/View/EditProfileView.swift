//
//  EditProfileView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 19.12.23.
//

import SwiftUI

struct EditProfileView: View {
    @StateObject var editProfileVM = EditProfileViewModel()
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
                    Text("Profile Photos")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    EditProfilePhotosView(editProfileVM: editProfileVM)
                }
                
                VStack(alignment: .leading, spacing: 10){
                    Text("Profile Info")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    TextField("", text: $editProfileVM.firstName)
                        .placeholder(when: editProfileVM.firstName.isEmpty) {
                            Text("First Name")
                                .foregroundColor(.secondary)
                                .bold()
                        }
                        .bold()
                        .createEventTabStyle()
                    
                    if firstNameError {
                        WarningTextComponent(text: "The field should contain at least 3 letters.")
                    }
                    
                    TextField("", text: $editProfileVM.lastName)
                        .placeholder(when: editProfileVM.lastName.isEmpty) {
                            Text("Last Name")
                                .foregroundColor(.secondary)
                                .bold()
                        }
                        .bold()
                        .createEventTabStyle()
                    
                    if lastNameError {
                        WarningTextComponent(text: "The field should contain at least 3 letters.")
                    }
                    
                    TextField("", text: $editProfileVM.occupation)
                        .placeholder(when: editProfileVM.lastName.isEmpty) {
                            Text("Occupation")
                                .foregroundColor(.secondary)
                                .bold()
                        }
                        .bold()
                        .createEventTabStyle()
                    
                    if occupationError {
                        WarningTextComponent(text: "The field should contain at least 3 letters.")
                    }
                    
                    TextField("", text: $editProfileVM.email)
                        .placeholder(when: editProfileVM.lastName.isEmpty) {
                            Text("Email")
                                .foregroundColor(.secondary)
                                .bold()
                        }
                        .bold()
                        .createEventTabStyle()
                    
                    if emailError {
                        WarningTextComponent(text: "Write a valid email.")
                    }
                    
                    NavigationLink(destination: EditProfileLocationView(editProfileVM: editProfileVM)){
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "location.circle.fill")
                                .imageScale(.large)
                            
                            if let location = editProfileVM.location {
                                Text(locationCityAndCountry(location))
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
                    
                    NavigationLink(destination: EditProfileGenderView(gender: $editProfileVM.gender, showGender: .constant(true))){
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "accessibility")
                                .imageScale(.large)
                            
                            
                            Text(editProfileVM.gender)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                            
                        }
                        .createEventTabStyle()
                    }
                    
                    NavigationLink(destination: EditProfileInterestView(selectedInterests: $editProfileVM.interests)){
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "circle.grid.2x2")
                                .imageScale(.large)
                            
                            if editProfileVM.interests.count > 0 {
                                Text(interestsOrder(editProfileVM.interests))
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
                    
                    EditProfileBioView(text: $editProfileVM.description, placeholder: "Bio")
                }
                
                VStack(alignment: .leading, spacing: 10){
                    Text("About Me")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Button{
                        sheetImage = Image(systemName: "graduationcap")
                        sheetTitle = "What's the level of your education?"
                        types = education
                        editProfileVM.selectedType = .education
                        showTypeSheet = true
                    } label:{
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "graduationcap")
                                .imageScale(.large)
                            
                            Text("Education")
                            
                            Spacer()
                            
                            if let education = editProfileVM.education{
                                Text(education)
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
                    
                    Button{
                        sheetImage = Image(systemName: "dumbbell")
                        sheetTitle = "How often do you workout?"
                        types = workout
                        editProfileVM.selectedType = .workout
                        showTypeSheet = true
                    } label:{
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "dumbbell")
                                .imageScale(.large)
                            
                            Text("Workout")
                            
                            Spacer()
                            
                            if let workout = editProfileVM.workout{
                                Text(workout)
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
                    
                    Button{
                        sheetImage = Image(systemName: "puzzlepiece.extension")
                        sheetTitle = "What's your personality type?"
                        types = personalityType
                        editProfileVM.selectedType = .personalityType
                        showTypeSheet = true
                    } label:{
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "puzzlepiece.extension")
                                .imageScale(.large)
                            
                            Text("Personality type")
                            
                            Spacer()
                            
                            if let personalityType = editProfileVM.personalityType{
                                Text(personalityType)
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
                    
                    Button{
                        showInstagramSheet = true
                    } label:{
                        HStack(alignment: .center, spacing: 10) {
                            Image("instagram")
                                .resizable()
                                .frame(width: 25, height: 25)
                            
                            Text("Instagarm")
                            
                            Spacer()
                            
                            if editProfileVM.instagram.isEmpty {
                                Text("Select")
                                    .foregroundColor(.gray)
                            } else {
                                Text(editProfileVM.instagram)
                                    .foregroundColor(.gray)
                            }
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                            
                        }
                        .createEventTabStyle()
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showTypeSheet, content: {
            SelectTabTypeView(image: sheetImage, title: sheetTitle, types: types, editProfileVM: editProfileVM)
        })
        .sheet(isPresented: $showInstagramSheet, content: {
            EditProfileInstagramView(instaText: $editProfileVM.instagram)
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
    
    
    var firstNameError: Bool {
        if editProfileVM.firstName.count < 3 && showError {
            return true
        } else {
            return false
        }
    }
    
    var lastNameError: Bool {
        if editProfileVM.lastName.count < 3 && showError {
            return true
        } else {
            return false
        }
    }
    
    var occupationError: Bool {
        if editProfileVM.occupation.count < 3 && showError {
            return true
        } else {
            return false
        }
    }
    
    var emailError: Bool {
        if !isValidEmail(testStr: editProfileVM.email) && showError {
            return true
        } else {
            return false
        }
    }
    
    var saveButtonCheck: Bool {
        if isValidEmail(testStr: editProfileVM.email) && editProfileVM.occupation.count >= 3 && editProfileVM.lastName.count >= 3 && editProfileVM.firstName.count >= 3 {
            return true
        } else {
            return false
        }
    }
    
}

#Preview {
    EditProfileView()
}
