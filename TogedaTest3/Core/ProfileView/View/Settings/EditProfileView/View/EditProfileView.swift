//
//  EditProfileView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 19.12.23.
//

import SwiftUI

struct EditProfileView: View {
    @StateObject var editProfileVM = EditProfileViewModel()
    @EnvironmentObject var userVM: UserViewModel
    
    @Environment(\.dismiss) var dismiss
    @State private var showTypeSheet = false
    @State private var showInstagramSheet = false
    @State private var showHeightSheet = false
    
    @State private var sheetImage: Image = Image(systemName: "")
    @State private var sheetTitle: String = ""
    @State private var types: [String] = []
    
    @State private var showError: Bool = false
    @State private var showGenderView: Bool = false
    @State private var showLocationView: Bool = false
    @State private var showInterestsView: Bool = false
    @State private var showPhoneNumberView: Bool = false
    
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
                    
                    TextField("", text: $editProfileVM.editUser.firstName)
                        .placeholder(when: editProfileVM.editUser.firstName.isEmpty) {
                            Text("First Name")
                                .foregroundColor(.secondary)
                                .bold()
                        }
                        .bold()
                        .createEventTabStyle()
                    
                    if firstNameError {
                        WarningTextComponent(text: "The field should contain at least 3 letters.")
                    }
                    
                    TextField("", text: $editProfileVM.editUser.lastName)
                        .placeholder(when: editProfileVM.editUser.lastName.isEmpty) {
                            Text("Last Name")
                                .foregroundColor(.secondary)
                                .bold()
                        }
                        .bold()
                        .createEventTabStyle()
                    
                    if lastNameError {
                        WarningTextComponent(text: "The field should contain at least 3 letters.")
                    }
                    
                    TextField("", text: $editProfileVM.editUser.occupation)
                        .placeholder(when: editProfileVM.editUser.occupation.isEmpty) {
                            Text("Occupation")
                                .foregroundColor(.secondary)
                                .bold()
                        }
                        .bold()
                        .createEventTabStyle()
                    
                    if occupationError {
                        WarningTextComponent(text: "The field should contain at least 3 letters.")
                    }
                    
                    
                    Button{
                        showLocationView = true
                    } label:{
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "location.circle.fill")
                                .imageScale(.large)
                            
                            Text(locationCityAndCountry(editProfileVM.editUser.location))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                            
                        }
                        .createEventTabStyle()
                    }
                    
                    Button{
                        showGenderView = true
                    } label:{
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "accessibility")
                                .imageScale(.large)
                            
                            
                            Text(editProfileVM.editUser.gender)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                            
                        }
                        .createEventTabStyle()
                    }
                    
                    Button{
                        showInterestsView = true
                    } label:{
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "circle.grid.2x2")
                                .imageScale(.large)
                            
                            if editProfileVM.editUser.interests.count > 0 {
                                Text(interestsOrder(editProfileVM.editUser.interests))
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
                    
                    if occupationError {
                        WarningTextComponent(text: "You need to pick at least 5 interests.")
                    }
                    
                    EditProfileBioView(text: $editProfileVM.description, placeholder: "Bio")
                }
                
                VStack(alignment: .leading, spacing: 10){
                    Text("Phone Number")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    NavigationLink(value: SelectionPath.editProfilePhoneNumberMain) {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "phone.fill")
                                .imageScale(.large)
                            
                            if let user = userVM.currentUser{
                                Text(user.phoneNumber.isEmpty ? "Enter Phone Number" : "+"+user.phoneNumber)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                        }
                    }
                    .createEventTabStyle()
                    
                    if let user = userVM.currentUser {
                        if !user.verifiedPhone{
                            HStack{
                                Image(systemName: "x.circle")
                                Text("You still haven't verified your number.")
                                    .foregroundStyle(.red)
                                    .font(.footnote)
                                    .bold()
                            }
                            .foregroundStyle(.red)
                        } else {
                            HStack{
                                Image(systemName: "checkmark.circle")

                                Text("Your phone number is verified")
                                    .font(.footnote)
                                    .bold()
                            }
                            .foregroundStyle(.green)
                        }
                    }
                    
                }
                
//                    if emailError {
//                        WarningTextComponent(text: "Write a valid email.")
//                    }
                
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
                            
                            if let education = editProfileVM.editUser.details.education{
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
                            
                            if let workout = editProfileVM.editUser.details.workout{
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
                        showHeightSheet = true
                    } label:{
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "ruler")
                                .imageScale(.large)
                                .rotationEffect(.degrees(115))
                            
                            Text("Height")
                            
                            Spacer()
                            
                            if let workout = editProfileVM.editUser.details.workout{
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
                    
                    if !validHeight {
                        WarningTextComponent(text: "Invalid height.")
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
                            
                            if let personalityType = editProfileVM.editUser.details.personalityType{
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
                            
                            if let instagram = editProfileVM.editUser.details.instagram {
                                Text(instagram)
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
        .sheet(isPresented: $showHeightSheet, content: {
            EditProfileHeightView(heightText: $editProfileVM.height)
        })
        .scrollIndicators(.hidden)
        .navigationTitle("Edit Profile")
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showGenderView, destination: {
            EditProfileGenderView(gender: $editProfileVM.editUser.gender, showGender: .constant(true))
        })
        .navigationDestination(isPresented: $showLocationView, destination: {
            EditProfileLocationView(editProfileVM: editProfileVM)
        })
        .navigationDestination(isPresented: $showInterestsView, destination: {
            EditProfileInterestView(selectedInterests: $editProfileVM.editUser.interests)
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
        .onAppear {
            if let user = userVM.currentUser, editProfileVM.isInit {
                editProfileVM.fetchUserData(currentUser: user)
                editProfileVM.isInit = false
            }
        } 
        
    }
    
    func save() {
        Task {
            do{
                if await editProfileVM.imageCheckAndMerge(){
                    if editProfileVM.editUser != editProfileVM.initialUser {
                        let data = try await UserService().editUserDetails(userData: editProfileVM.editUser, phoneNumber: nil)
                        print("Success: \(data)")
                        try await userVM.fetchCurrentUser()
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
    
    var interestsError: Bool {
        if editProfileVM.editUser.interests.count < 5 && showError {
            return true
        } else {
            return false
        }
    }
    
    var firstNameError: Bool {
        if editProfileVM.editUser.firstName.count < 3 && showError {
            return true
        } else {
            return false
        }
    }
    
    var lastNameError: Bool {
        if editProfileVM.editUser.lastName.count < 3 && showError {
            return true
        } else {
            return false
        }
    }
    
    var occupationError: Bool {
        if editProfileVM.editUser.occupation.count < 3 && showError {
            return true
        } else {
            return false
        }
    }
    
    var saveButtonCheck: Bool {
        if editProfileVM.editUser.occupation.count >= 3 && editProfileVM.editUser.lastName.count >= 3 && editProfileVM.editUser.firstName.count >= 3, editProfileVM.editUser.interests.count >= 5 &&
            validHeight
        {
            return true
        } else {
            return false
        }
    }
    
    var validHeight: Bool {
        if let height = Int(editProfileVM.height) {
            if height > 280 {
                return false
            } else if height < 60 {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
}

#Preview {
    EditProfileView()
        .environmentObject(UserViewModel())
}
