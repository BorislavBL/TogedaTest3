//
//  EditProfileGenderView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 21.12.23.
//

import SwiftUI

struct EditProfileGenderView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @Binding var gender: String
    @Binding var showGender: Bool
    
    var body: some View {
        VStack {
            Text("What's your gender?")
                .multilineTextAlignment(.center)
                .font(.title).bold()
                .padding(.top, 20)
            
            genderButton(title: "Man")
                .padding(.bottom, 4)
            genderButton(title: "Woman")
                .padding(.bottom, 15)
            
            Button{
                showGender.toggle()
            } label: {
                HStack(alignment: .center, spacing: 16, content: {
                    Image(systemName: showGender ? "checkmark.square.fill" : "square")
                    Text("Make my gender visisble to others.")
                        .multilineTextAlignment(.leading)
                        .bold()
                    
                })
                .foregroundStyle(.gray)
            }
            
            Spacer()
            
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
            gender = title
        } label:{
            Text(title)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(gender == title ? Color("blackAndWhite") : Color(.tertiarySystemFill))
                .foregroundColor(gender == title ? Color("testColor") : .accentColor)
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
    EditProfileGenderView( gender: .constant("Male"), showGender: .constant(true))
}
