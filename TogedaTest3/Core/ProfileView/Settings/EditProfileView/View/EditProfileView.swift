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
    @EnvironmentObject var navManager: NavigationManager
    @StateObject var photoPickerVM = PhotoPickerViewModel(s3BucketName: .user, mode: .edit)
    
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
    @State private var showPasswordView = false
    
    @State var isLoading = false
    @State private var errorMessage: String?
    

    
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment: .leading, spacing: 30){
                
                if let error = errorMessage {
                    WarningTextComponent(text: error)
                }
                
                VStack(alignment: .leading, spacing: 10){
                    Text("Profile Photos")
                        .font(.title3)
                        .fontWeight(.bold)
                    
//                    EditProfilePhotosView(editProfileVM: editProfileVM)
                    PhotosGridView(images: $editProfileVM.editUser.profilePhotos, vm: photoPickerVM)
                    
                    if noPhotos {
                        WarningTextComponent(text: "You must have at least one photo.")
                    }
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
                    } else if (!containsOnlyLetters(editProfileVM.editUser.firstName)) && showError {
                        WarningTextComponent(text: "Please use only letters for your name.")
                            .padding(.bottom, 15)
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
                    } else if (!containsOnlyLetters(editProfileVM.editUser.lastName)) && showError {
                        WarningTextComponent(text: "Please use only letters for your name.")
                            .padding(.bottom, 15)
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
                            
                            
                            Text(editProfileVM.editUser.gender.rawValue.capitalized)
                            
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
                                Text(interestsOrder1(editProfileVM.editUser.interests))
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
                    
                    Button{
                        showPasswordView = true
                    } label:{
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "lock.circle")
                                .imageScale(.large)
                            
                            Text("Change Password")
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                            
                        }
                        .createEventTabStyle()
                    }
                    
                    EditProfileBioView(text: $editProfileVM.description, placeholder: "Bio")
                }
                
//                VStack(alignment: .leading, spacing: 10){
//                    Text("Phone Number")
//                        .font(.title3)
//                        .fontWeight(.bold)
//                    
//                    NavigationLink(value: SelectionPath.editProfilePhoneNumberMain) {
//                        HStack(alignment: .center, spacing: 10) {
//                            Image(systemName: "phone.fill")
//                                .imageScale(.large)
//                            
//                            if let user = userVM.currentUser{
//                                Text(user.phoneNumber.isEmpty ? "Enter Phone Number" : "+"+user.phoneNumber)
//                            }
//                            
//                            Spacer()
//                            
//                            Image(systemName: "chevron.right")
//                                .padding(.trailing, 10)
//                                .foregroundColor(.gray)
//                            
//                        }
//                    }
//                    .createEventTabStyle()
//                    
//                    if let user = userVM.currentUser {
//                        if !user.verifiedPhone{
//                            HStack{
//                                Image(systemName: "x.circle")
//                                Text("You still haven't verified your number.")
//                                    .foregroundStyle(.red)
//                                    .font(.footnote)
//                                    .bold()
//                            }
//                            .foregroundStyle(.red)
//                        } else {
//                            HStack{
//                                Image(systemName: "checkmark.circle")
//
//                                Text("Your phone number is verified")
//                                    .font(.footnote)
//                                    .bold()
//                            }
//                            .foregroundStyle(.green)
//                        }
//                    }
//                    
//                }
                
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
                            
                            if let height = editProfileVM.editUser.details.height{
                                Text("\(height) cm")
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
                            
                            Text("Instagram")
                            
                            Spacer()
                            
                            if let instagram = editProfileVM.editUser.details.instagram, !instagram.isEmpty {
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
                    
                    HStack(alignment: .top, spacing: 16, content: {
                        Button{
                            editProfileVM.editUser.subToEmail.toggle()
                        } label: {
                            Image(systemName: editProfileVM.editUser.subToEmail ? "checkmark.square.fill" : "square")
                            
                        }
                        
                        HStack(alignment: .top, spacing: 16, content: {
                            Text("I agree to receive email updates from Togeda about events, products, apps, news, and other information included in our ")
                                .foregroundStyle(.gray)
                                .font(.footnote)
                                .bold() +
                            Text(directMarketingAgreement)
                                .font(.footnote)
                                .bold() +
                            Text(".")
                                .foregroundStyle(.gray)
                                .font(.footnote)
                                .bold()
                        })
                        .accentColor(.blue)
                    })
                    .multilineTextAlignment(.leading)
                    .createEventTabStyle()
                }
            }
            .padding()
        }
        .overlay {
            if isLoading {
                LoadingScreenView(isVisible: $isLoading)
            }
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
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showGenderView, destination: {
            EditProfileGenderView(gender: $editProfileVM.editUser.gender, showGender: $editProfileVM.editUser.visibleGender)
        })
        .navigationDestination(isPresented: $showLocationView, destination: {
            EditProfileLocationView(editProfileVM: editProfileVM)
        })
        .navigationDestination(isPresented: $showInterestsView, destination: {
            EditProfileInterestView(selectedInterests: $editProfileVM.interests)
        })
        .navigationDestination(isPresented: $showPasswordView, destination: {
            ChangePasswordView()
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
                editProfileVM.fetchUserData(user: user)
                editProfileVM.isInit = false
            }
        }
        .swipeBack()
        
    }
    
    func save() {
        errorMessage = nil
        Task {
            do{
                if await photoPickerVM.imageCheckAndMerge(images: $editProfileVM.editUser.profilePhotos){
                    withAnimation{
                        isLoading = true
                    }
                    if editProfileVM.editUser != editProfileVM.initialUser {
                        editProfileVM.editUser.firstName = trimAndLimitWhitespace(editProfileVM.editUser.firstName)
                        editProfileVM.editUser.lastName = trimAndLimitWhitespace(editProfileVM.editUser.lastName)
                        editProfileVM.editUser.occupation = trimAndLimitWhitespace(editProfileVM.editUser.occupation)
                        if let bio = editProfileVM.editUser.details.bio {
                            editProfileVM.editUser.details.bio = trimAndLimitWhitespace(bio)
                        }
                       try await APIClient.shared.updateUserInfo(body: editProfileVM.convertToPathcUser(currentUser: editProfileVM.editUser)) { response, error in
                           if let response = response {
    
                               Task{
                                   try await userVM.fetchCurrentUser()
                               }
                               DispatchQueue.main.async {
                                   withAnimation{
                                       self.isLoading = false
                                   }
                                   if navManager.selectionPath.count >= 2 {
                                       navManager.selectionPath.removeLast(2)
                                   }
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
                        withAnimation{
                            isLoading = false
                        }
                        print("No changes")
                        if navManager.selectionPath.count >= 2{
                            navManager.selectionPath.removeLast(2)
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
        if containsOnlyLetters(editProfileVM.editUser.firstName) && containsOnlyLetters(editProfileVM.editUser.lastName) && editProfileVM.editUser.occupation.count >= 3 && editProfileVM.editUser.lastName.count >= 3 && editProfileVM.editUser.firstName.count >= 3 && editProfileVM.editUser.interests.count >= 5 &&
            validHeight && (editProfileVM.editUser != editProfileVM.initialUser || photoPickerVM.imageIsSelected()), (photoPickerVM.selectedImages.contains(where: { $0 != nil }) || editProfileVM.editUser.profilePhotos.count > 0)
        {
            return true
        } else {
            return false
        }
    }
    
    var noPhotos: Bool {
        if editProfileVM.editUser.profilePhotos.count == 0 && photoPickerVM.selectedImages.allSatisfy({ $0 == nil }) && showError{
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
        .environmentObject(NavigationManager())
}
