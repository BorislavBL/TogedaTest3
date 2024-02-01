//
//  RegistrationFullNameView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 14.12.23.
//

import SwiftUI

struct RegistrationFullNameView: View {
    enum FocusedField: Hashable{
        case first, last
    }
    
    @ObservedObject var vm: RegistrationViewModel
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var focus: FocusedField?
    @Environment(\.dismiss) var dismiss
    @State private var displayError: Bool = false
    @State private var isActive: Bool = false
    var body: some View {
        VStack {
            Text("What's your name?")
                .multilineTextAlignment(.center)
                .font(.title).bold()
                .padding(.top, 20)
            
            TextField("", text: $vm.createdUser.firstName)
                .placeholder(when: vm.createdUser.firstName.isEmpty) {
                    Text("First Name")
                        .foregroundColor(.secondary)
                        .bold()
                }
                .bold()
                .focused($focus, equals: .first)
                .submitLabel(.next)
                .onSubmit {
                    focus = .last
                }
                .padding(10)
                .frame(minWidth: 80, minHeight: 47)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(.top, 20)
            
            TextField("", text: $vm.createdUser.lastName)
                .placeholder(when: vm.createdUser.lastName.isEmpty) {
                    Text("Last Name")
                        .foregroundColor(.secondary)
                        .bold()
                }
                .bold()
                .focused($focus, equals: .last)
                .submitLabel(.next)
                .onSubmit {
                    if vm.createdUser.firstName.count < 3 || vm.createdUser.lastName.count < 3 {
                        displayError.toggle()
                    } else {
                        isActive = true
                    }
                }
                .padding(10)
                .frame(minWidth: 80, minHeight: 47)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(.top, 2)
                .padding(.bottom, 15)
            
            if displayError {
                WarningTextComponent(text: "Each of the fields has to be at least 3 characters long.")
                    .padding(.bottom, 15)
            }
            
            Text("That's how the other users will see you in Togeda")
                .bold()
                .foregroundStyle(.gray)
            
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
            .disableWithOpacity((vm.createdUser.firstName.count < 3 || vm.createdUser.lastName.count < 3))
            .onTapGesture {
                if vm.createdUser.firstName.count < 3 || vm.createdUser.lastName.count < 3 {
                    displayError.toggle()
                }
            }
            
        }
        .animation(.easeInOut(duration: 0.6), value: focus)
        .padding(.horizontal)
        
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear{
            focus = .first
        }
        
        .ignoresSafeArea(.keyboard)
        .padding(.vertical)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $isActive, destination: {
            RegistartionAgeView(vm: vm)
        })
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
    RegistrationFullNameView(vm: RegistrationViewModel())
}
