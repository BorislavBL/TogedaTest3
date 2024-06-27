//
//  CreateEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import MapKit

struct CreateEventView: View {
    var fromClub: Components.Schemas.ClubDto? = nil
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var showExitSheet: Bool = false
    @State private var displayWarnings: Bool = false
    @StateObject var ceVM = CreateEventViewModel()
    @State var Init: Bool = true
    
    
    //PhotoPicker
    @StateObject var photoPickerVM = PhotoPickerViewModel(s3BucketName: .post, mode: .normal)
    
    @State private var showDescriptionView: Bool = false
    @State private var showPhotosView: Bool = false
    @State private var showLocationView: Bool = false
    @State private var showAccessibilityView: Bool = false
    @State private var showInterestsView: Bool = false
    
    let descriptionPlaceholder = "Describe the purpose of your event. What activities are you planning? Mention any special guests who might be attending. Will there be food and drinks? Help attendees know what to expect."
    
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        NavigationStack() {
            ZStack(alignment: .bottom){
                ScrollView(showsIndicators: false){
                    VStack(alignment: .leading){
                        Text("Title:")
                            .foregroundStyle(.tint)
                        TextField("What event would you like to make?", text: $ceVM.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .autocorrectionDisabled(true)
                            .onChange(of: ceVM.title) { oldValue, newValue in
                                if ceVM.title.count > 70 {
                                    ceVM.title = String(ceVM.title.prefix(70))
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
                    
                    
                    Button{
                        showDescriptionView = true
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "square.and.pencil")
                                .imageScale(.large)
                            
                            
                            Text("Description")
                            
                            Spacer()
                            
                            Text(ceVM.description)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing, 10)
                                .foregroundColor(.gray)
                            
                        }
                        .createEventTabStyle()
                    }
                    
                    Button{
                        showPhotosView = true
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "photo")
                                .foregroundStyle(.tint)
                            Text("Photos")
                                .foregroundStyle(.tint)
                            Spacer()
                            
                            if photoPickerVM.selectedImages.contains(where: {$0 != nil}) {
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
                        showLocationView = true
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "mappin.circle")
                                .imageScale(.large)
                            
                            
                            Text("Location")
                            
                            Spacer()
                            
                            if let location = ceVM.location {
                                Text(location.name)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
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
                        showAccessibilityView = true
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "eye.circle")
                                .imageScale(.large)
                            
                            
                            Text("Accessibility")
                            
                            Spacer()
                            
                            if !ceVM.selectedVisability.isEmpty {
                                Text(ceVM.selectedVisability.capitalized)
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
                    
                    if noVisability {
                        WarningTextComponent(text: "Please select a visability type.")
                        
                    }
                    
                    Button {
                        showInterestsView = true
                    } label: {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "circle.grid.2x2")
                                .imageScale(.large)
                            
                            if $ceVM.selectedInterests.count > 0 {
                                Text(interestsOrder(ceVM.selectedInterests))
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
                    
                    //                    NavigationLink {
                    //                        DateView(isDate: $ceVM.isDate, date: $ceVM.date, from: $ceVM.from, to: $ceVM.to, daySettings: $ceVM.daySettings, timeSettings: $ceVM.timeSettings)
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
                    //                            Text(ceVM.isDate ? separateDateAndTime(from:ceVM.date).date : "Any day")
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
                            ceVM.showTimeSettings.toggle()
                        } label: {
                            HStack(alignment: .center, spacing: 10) {
                                Image(systemName: "calendar")
                                    .imageScale(.large)
                                
                                
                                Text("Date & Time")
                                
                                Spacer()
                                
                                if ceVM.dateTimeSettings == 0 {
                                    Text(separateDateAndTime(from:ceVM.from).date)
                                        .foregroundColor(.gray)
                                } else if ceVM.dateTimeSettings == 1 {
                                    Text("\(separateDateAndTime(from:ceVM.from).date) - \(separateDateAndTime(from:ceVM.to).date)")
                                        .foregroundColor(.gray)
                                } else {
                                    Text("Anyday")
                                        .foregroundColor(.gray)
                                }
                                
                                Image(systemName: ceVM.showTimeSettings ? "chevron.down" : "chevron.right")
                                    .padding(.trailing, 10)
                                    .foregroundColor(.gray)
                                
                            }
                            
                        }
                        
                        if ceVM.showTimeSettings {
                            Picker("Choose Date", selection: $ceVM.dateTimeSettings){
                                Text("Exact").tag(0)
                                Text("Range").tag(1)
                                Text("Anytime").tag(2)
                            }
                            .pickerStyle(.segmented)
                            
                            if ceVM.dateTimeSettings != 2 {
                                DatePicker("From", selection: $ceVM.from, in: Date().addingTimeInterval(900)..., displayedComponents: [.date, .hourAndMinute])
                                    .fontWeight(.semibold)
                                
                                if ceVM.dateTimeSettings == 1 {
                                    DatePicker("To", selection: $ceVM.to, in: ceVM.from.addingTimeInterval(600)..., displayedComponents: [.date, .hourAndMinute])
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
                    
                    if pastDate {
                        WarningTextComponent(text: "Chnage your timeframe. You can't create an event in the past.")
                        
                    }
                    
                    VStack(alignment: .leading, spacing: 20){
                        
                        Button {
                            ceVM.showParticipants.toggle()
                        } label: {
                            
                            HStack(alignment: .center, spacing: 10) {
                                Image(systemName: "person.2.circle")
                                    .imageScale(.large)
                                
                                
                                Text("Participants")
                                
                                Spacer()
                                
                                if let participant = ceVM.participants{
                                    Text(participant > 0 ? "\(participant)" : "No Limit")
                                        .foregroundColor(.gray)
                                } else {
                                    Text("No Limit")
                                        .foregroundColor(.gray)
                                }
                                
                                Image(systemName: ceVM.showParticipants ? "chevron.down" : "chevron.right")
                                    .padding(.trailing, 10)
                                    .foregroundColor(.gray)
                                
                            }
                            
                        }
                        if ceVM.showParticipants {
                            HStack(alignment: .center, spacing: 10) {
                                Text("The number of participants")
                                
                                Spacer()
                                
                                TextField("Max", value: $ceVM.participants, format:.number)
                                    .foregroundColor(.gray)
                                    .frame(width: 70)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                
                            }
                            
                        }
                    }
                    .createEventTabStyle()
                    
                    if let user = userVM.currentUser {
                        VStack(alignment: .leading, spacing: 20){
                            Button {
                                ceVM.showPricing.toggle()
                            } label: {
                                
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "wallet.pass")
                                        .imageScale(.large)
                                    
                                    
                                    Text("Price")
                                    
                                    Spacer()
                                    
                                    if let price = ceVM.price{
                                        
                                        Text(price > 0.0 ? "€ \(price, specifier: "%.2f")" : "Free")
                                            .foregroundColor(.gray)
                                    } else {
                                        Text("Free")
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Image(systemName: ceVM.showPricing ? "chevron.down" : "chevron.right")
                                        .padding(.trailing, 10)
                                        .foregroundColor(.gray)
                                    
                                }
                                
                            }
                            if ceVM.showPricing {
                                if user.stripeAccountId != nil{
                                    HStack(alignment: .center, spacing: 10) {
                                        Text("Write a Price")
                                        
                                        Spacer()
                                        
                                        TextField("€ 0.00", value: $ceVM.price, format:.currency(code: "EUR"))
                                            .foregroundColor(.gray)
                                            .frame(width: 70)
                                            .textFieldStyle(.roundedBorder)
                                            .keyboardType(.numberPad)
                                        
                                        
                                    }
                                } else {
                                    VStack(alignment: .center){
                                        Text("To create a paid event frist create a Stripe account!")
                                            .foregroundColor(Color("blackAndWhite"))
                                            .fontWeight(.semibold)
                                            .multilineTextAlignment(.center)
                                            .padding(.bottom)
                                        
                                        Button{
                                            Task{
                                                if let accountId = try await APIClient.shared.createStripeAccount() {
                                                    print(accountId)
                                                    if let link = try await APIClient.shared.getStripeOnBoardingLink(accountId: accountId) {
                                                        print(link)
                                                        openURL(URL(string: link)!)
                                                        dismiss()
                                                    }
                                                }
                                            }
                                            
                                        } label: {
                                            Text("Go to Stripe")
                                                .foregroundStyle(Color("base"))
                                                .fontWeight(.semibold)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 10)
                                                .background{Capsule().fill(Color("blackAndWhite"))}
                                        }
                                    }
                                    .padding(.bottom)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                }
                                
                            }
                        }
                        .createEventTabStyle()
                        .padding(.bottom, 100)
                    }
                }
                .padding(.horizontal)
                
                
                if allRequirenments {
                    ZStack(alignment: .bottom){
                        LinearGradient(colors: [.base, .clear], startPoint: .bottom, endPoint: .top)
                            .ignoresSafeArea(edges: .bottom)

                        Button{
                            Task{
                                do{
                                    if await photoPickerVM.saveImages() {
                                        ceVM.postPhotosURls = photoPickerVM.publishedPhotosURLs
                                        let createPost = ceVM.createPost()
                                        _ = try await APIClient.shared.createEvent(body: createPost)
                                        dismiss()
                                    } else {
                                        print("Problem with image")
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
                    }
                    .frame(height: 60)
                } else {
                    ZStack(alignment: .bottom){
                        LinearGradient(colors: [.base, .clear], startPoint: .bottom, endPoint: .top)
                            .ignoresSafeArea(edges: .bottom)

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
                    .frame(height: 60)
                }
                
            }
            .scrollDismissesKeyboard(.immediately)
            .onAppear(){
                if Init{
                    ceVM.club = fromClub
                    Init = false
                }
            }
            .toolbar{
                ToolbarItemGroup(placement: .keyboard) {
                    KeyboardToolbarItems()
                }
            }
            .frame(maxHeight: UIScreen.main.bounds.height, alignment: .top)
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:Button(action: {showExitSheet = true}) {
                Image(systemName: "xmark")
                    .imageScale(.medium)
                    .padding(.all, 8)
                    .background(Color("main-secondary-color"))
                    .clipShape(Circle())
            }
            )
            .navigationDestination(isPresented: $showDescriptionView) {
                DescriptionView(description: $ceVM.description, placeholder: descriptionPlaceholder)
            }
            .navigationDestination(isPresented: $showPhotosView) {
                PhotoPickerView(photoPickerVM: photoPickerVM)
            }
            .navigationDestination(isPresented: $showLocationView) {
                LocationPicker(returnedPlace: $ceVM.returnedPlace, isActivePrev: $showLocationView)
            }
            .navigationDestination(isPresented: $showAccessibilityView) {
                AccessibilityView(selectedVisability: $ceVM.selectedVisability, askToJoin: $ceVM.askToJoin, selectedClub: $ceVM.club)
            }
            .navigationDestination(isPresented: $showInterestsView) {
                CategoryView(selectedInterests: $ceVM.selectedInterests, text: "Select at least one tag related to your event", minInterests: 0)
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
        if ceVM.title.isEmpty && displayWarnings {
            return true
        } else {
            return false
        }
    }
    
    var titleChartLimit: Bool {
        if !ceVM.title.isEmpty && displayWarnings && ceVM.title.count < 5 {
            return true
        } else {
            return false
        }
    }
    
    var noPhotos: Bool {
        if photoPickerVM.selectedImages.allSatisfy({ $0 == nil }) && displayWarnings{
            return true
        } else {
            return false
        }
    }
    
    var noLocation: Bool {
        if ceVM.returnedPlace.name == "Unknown Location" && displayWarnings {
            return true
        } else {
            return false
        }
    }
    
    var noVisability: Bool {
        if ceVM.selectedVisability.isEmpty && displayWarnings {
            return true
        } else {
            return false
        }
    }
    
    var noTag: Bool {
        if ceVM.selectedInterests.count == 0 && displayWarnings {
            return true
        } else {
            return false
        }
    }
    
    var pastDate: Bool {
        if ceVM.from <= Date() && displayWarnings {
            return true
        } else {
            return false
        }
    }
    
    var allRequirenments: Bool {
        if ceVM.title.count >= 5, !ceVM.title.isEmpty, ceVM.returnedPlace.name != "Unknown Location", photoPickerVM.selectedImages.contains(where: { $0 != nil }),
           ceVM.selectedInterests.count > 0 && !ceVM.selectedVisability.isEmpty && ceVM.from > Date() {
            return true
        } else {
            return false
        }
    }
}

#Preview{
    CreateEventView()
        .environmentObject(UserViewModel())
        .environmentObject(LocationManager())
}

extension View {
    func createEventTabStyle() -> some View {
        self.font(.subheadline)
            .fontWeight(.semibold)
            .padding(.vertical, 5)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .normalTagRectangleStyle()
    }
}
