//
//  RegisterOccupationView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.12.23.
//

import SwiftUI

struct RegistrationOccupationView: View {
    @ObservedObject var vm: RegistrationViewModel
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var keyIsFocused: Bool
    @Environment(\.dismiss) var dismiss
    
    @State var isStudent: Bool = false
    @State private var displayError: Bool = false
    @State private var isActive: Bool = false
    @ObservedObject var photoVM: PhotoPickerViewModel
    
    var body: some View {
        VStack {
            Text("What do you do?")
                .multilineTextAlignment(.center)
                .font(.title).bold()
                .padding(.top, 20)
            
            TextField("", text: $vm.occupation)
                .placeholder(when: vm.occupation.isEmpty) {
                    Text("Occupation")
                        .foregroundColor(.secondary)
                        .bold()
                }
                .bold()
                .focused($keyIsFocused)
                .keyboardType(.default)
                .submitLabel(.next)
                .onSubmit {
                    if vm.occupation.isEmpty && !isStudent{
                        displayError.toggle()
                    } else {
                        isActive = true
                    }
                }
                .padding(10)
                .frame(minWidth: 80, minHeight: 47)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(.top, 20)
                .padding(.bottom, 15)
            
            
            if displayError {
                WarningTextComponent(text: "Please fill in the field")
                    .padding(.bottom, 15)
            }
            
            Button{
                isStudent.toggle()
                if isStudent {
                    vm.occupation = "Student"
                } else {
                    vm.occupation = ""
                }
            } label: {
                HStack(alignment: .center, spacing: 16, content: {
                    Image(systemName: isStudent ? "checkmark.square.fill" : "square")
                    Text("I am a student")
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
            .disableWithOpacity(vm.occupation.isEmpty && !isStudent)
            .onTapGesture {
                if vm.occupation.isEmpty && !isStudent{
                    displayError.toggle()
                }
            }
            
        }
        .animation(.easeInOut(duration: 0.6), value: keyIsFocused)
        .padding(.horizontal)
        .onAppear(){
            keyIsFocused = true
        }
        .toolbar{
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardToolbarItems()
            }
        }
        .padding(.vertical)
        .swipeBack()
        .navigationDestination(isPresented: $isActive, destination: {
            RegistrationPhotosView(vm: vm, photoVM: photoVM)
        })
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .frame(width: 35, height: 35)
                .background(Color(.tertiarySystemFill))
                .clipShape(Circle())
        })
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
    RegistrationOccupationView(vm: RegistrationViewModel(), photoVM: PhotoPickerViewModel(s3BucketName: .user, mode: .normal))
}
