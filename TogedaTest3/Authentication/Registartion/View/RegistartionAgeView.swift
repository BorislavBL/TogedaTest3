//
//  RegistartionAgeView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 14.12.23.
//

import SwiftUI

struct RegistartionAgeView: View {
    enum FocusedField: Hashable{
        case day,month,year
    }
    @ObservedObject var vm: RegistrationViewModel
    @ObservedObject var photoVM: PhotoPickerViewModel
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var focus: FocusedField?
    @Environment(\.dismiss) var dismiss

    @State private var displayError: Bool = false
    @State private var isActive: Bool = false
    
    var body: some View {
        VStack {
            Text("What's your birthday?")
                .multilineTextAlignment(.center)
                .font(.title).bold()
                .padding(.top, 20)
            
            HStack{
                TextField("", text: $vm.day)
                    .placeholder(when: vm.day.isEmpty) {
                        Text("DD")
                            .foregroundColor(.secondary)
                            .bold()
                    }
                    .bold()
                    .focused($focus, equals: .day)
                    .submitLabel(.next)
                    .keyboardType(.numberPad)
                    .onChange(of: vm.day) {
                        if vm.day.count >= 2 {
                            vm.day = String(vm.day.prefix(2))
                            focus = .month
                        }
                    }
                
                Text("/")
                
                TextField("", text: $vm.month)
                    .placeholder(when: vm.month.isEmpty) {
                        Text("MM")
                            .foregroundColor(.secondary)
                            .bold()
                    }
                    .bold()
                    .focused($focus, equals: .month)
                    .submitLabel(.next)
                    .keyboardType(.numberPad)
                    .onChange(of: vm.month) {
                        if vm.month.count >= 2 {
                            vm.month = String(vm.month.prefix(2))
                            focus = .year
                        }
                    }
                
                Text("/")
                
                TextField("", text: $vm.year)
                    .placeholder(when: vm.year.isEmpty) {
                        Text("YYYY")
                            .foregroundColor(.secondary)
                            .bold()
                    }
                    .bold()
                    .focused($focus, equals: .year)
                    .submitLabel(.next)
                    .keyboardType(.numberPad)
                    .onSubmit(){
                        if !hasAge(day: vm.day, month: vm.month, year: vm.year){
                            displayError.toggle()
                        } else {
                            isActive = true
                        }
                    }
                    .onChange(of: vm.year) {
                        if vm.year.count >= 4 {
                            vm.year = String(vm.year.prefix(4))
                        }
                    }

            }
            .padding(10)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.top, 2)
            .padding(.bottom, 15)
            
            if displayError && !validDate(day: vm.day, month: vm.month, year: vm.year){
                WarningTextComponent(text: "Please write a valid date.")
                    .padding(.bottom, 15)
            } else if displayError && !hasAge(day: vm.day, month: vm.month, year: vm.year){
                WarningTextComponent(text: "You must be at least 18 years old.")
                    .padding(.bottom, 15)
            } else if displayError && !validAge(day: vm.day, month: vm.month, year: vm.year){
                WarningTextComponent(text: "You can't be that old...")
                    .padding(.bottom, 15)
            }
            
            

            Text("Your age will be visible to others")
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
            .disableWithOpacity(!hasAge(day: vm.day, month: vm.month, year: vm.year) || !validAge(day: vm.day, month: vm.month, year: vm.year))
            .onTapGesture {
                if !hasAge(day: vm.day, month: vm.month, year: vm.year) || !validAge(day: vm.day, month: vm.month, year: vm.year){
                    displayError.toggle()
                }
            }
            
        }
        .animation(.easeInOut(duration: 0.6), value: focus)
        .padding(.horizontal)
        .toolbar{
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardToolbarItems()
            }
        }
        .onAppear{
            focus = .day
        }
        .padding(.vertical)
        .navigationDestination(isPresented: $isActive, destination: {
            RegistrationGenderView(vm: vm, photoVM: photoVM)
        })
        .swipeBack()
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .frame(width: 35, height: 35)
                .background(Color(.tertiarySystemFill))
                .clipShape(Circle())
        })
    }
    
    func formatSingleDigit(_ numberStr: String) -> String {
        if numberStr.count == 1, let _ = Int(numberStr) {
            return "0\(numberStr)"
        }
        return numberStr
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
    RegistartionAgeView(vm: RegistrationViewModel(), photoVM: PhotoPickerViewModel(s3BucketName: .user, mode: .normal))
}
