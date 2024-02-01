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

    var body: some View {
        VStack {
            Text("What's your gender?")
                .multilineTextAlignment(.center)
                .font(.title).bold()
                .padding(.top, 20)
            
            genderButton(title: "Male")
                .padding(.bottom, 4)
            genderButton(title: "Female")
                .padding(.bottom, 15)
            
            if displayError {
                WarningTextComponent(text: "Please select your gender.")
                    .padding(.bottom, 15)
            }
            
            Button{
                vm.createdUser.visibleGender.toggle()
            } label: {
                HStack(alignment: .center, spacing: 16, content: {
                    Image(systemName: vm.createdUser.visibleGender ? "checkmark.square.fill" : "square")
                    Text("Make my gender visisble to others.")
                        .multilineTextAlignment(.leading)
                        .bold()
                    
                })
                .foregroundStyle(.gray)
            }
            
            Spacer()
            
            NavigationLink(destination: RegistrationLocationView(vm: vm)){
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .cornerRadius(10)
                    .fontWeight(.semibold)
            }
            .disableWithOpacity(vm.createdUser.gender.isEmpty)
            .onTapGesture {
                if vm.createdUser.gender.isEmpty {
                    displayError.toggle()
                }
            }
            
        }
        .padding(.horizontal)
        .padding(.vertical)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .frame(width: 35, height: 35)
                .background(Color(.tertiarySystemFill))
                .clipShape(Circle())
        })
    }
    
    @ViewBuilder
    func genderButton(title: String) -> some View {
        Button{
            vm.createdUser.gender = title.uppercased()
        } label:{
            Text(title)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(vm.createdUser.gender == title.uppercased() ? Color("blackAndWhite") : Color(.tertiarySystemFill))
                .foregroundColor(vm.createdUser.gender == title.uppercased() ? Color("testColor") : .accentColor)
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
    RegistrationGenderView(vm: RegistrationViewModel())
}
