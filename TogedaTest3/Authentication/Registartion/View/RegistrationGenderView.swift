//
//  RegistrationGenderView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.12.23.
//

import SwiftUI

struct RegistrationGenderView: View {
    @ObservedObject var vm: RegistrationViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var displayError: Bool = false
    @State private var isActive: Bool = false
    @ObservedObject var photoVM: PhotoPickerViewModel

    var body: some View {
        VStack {
            Text("What's your gender?")
                .multilineTextAlignment(.center)
                .font(.title).bold()
                .padding(.top, 20)
            
            genderButton(title: .MALE)
                .padding(.bottom, 4)
            genderButton(title: .FEMALE)
                .padding(.bottom, 15)
            
            if displayError {
                WarningTextComponent(text: "Please select your gender.")
                    .padding(.bottom, 15)
            }
            
            Button{
                vm.visibleGender.toggle()
            } label: {
                HStack(alignment: .center, spacing: 16, content: {
                    Image(systemName: vm.visibleGender ? "checkmark.square.fill" : "square")
                    Text("Make my gender visisble to others.")
                        .multilineTextAlignment(.leading)
                        .bold()
                    
                })
                .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Button{
                isActive = true
            } label:{
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .cornerRadius(10)
                    .fontWeight(.semibold)
            }
            .disableWithOpacity(vm.gender == nil)
            .onTapGesture {
                if vm.gender == nil {
                    displayError.toggle()
                }
            }
            
        }
        .padding(.horizontal)
        .padding(.vertical)
        .swipeBack()
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .frame(width: 35, height: 35)
                .background(Color(.tertiarySystemFill))
                .clipShape(Circle())
        })
        .navigationDestination(isPresented: $isActive) {
            RegistrationLocationView(vm: vm, photoVM: photoVM)
        }
    }
    
    @ViewBuilder
    func genderButton(title: Components.Schemas.UserDto.genderPayload) -> some View {
        Button{
            vm.gender = title
        } label:{
            Text(title.rawValue.capitalized)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(vm.gender == title ? Color("blackAndWhite") : Color(.tertiarySystemFill))
                .foregroundColor(vm.gender == title ? Color("testColor") : .accentColor)
                .cornerRadius(10)
                .fontWeight(.semibold)
        }
    }
    
    var foregroundColor: Color {
        if colorScheme == .dark {
            return Color(.white)
        } else {
            return Color(.black)
        }
    }
    
    var backgroundColor: Color {
        if colorScheme == .dark {
            return Color(.systemGray5)
        } else {
            return Color(.systemGray6)
        }
    }
}

#Preview {
    RegistrationGenderView(vm: RegistrationViewModel(), photoVM: PhotoPickerViewModel(s3BucketName: .user, mode: .normal))
}
