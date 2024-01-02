//
//  RegistartionInterestsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.12.23.
//

import SwiftUI
import WrappingHStack

struct RegistartionInterestsView: View {
    @Binding var selectedInterests: [String]
    @Environment(\.dismiss) private var dismiss
    let categories = CategoryOptions.dropLast()
    @Environment(\.colorScheme) var colorScheme
    @State private var displayError: Bool = false
    
    var body: some View {
        VStack {
            ScrollView(){
                
                LazyVStack(alignment: .center, spacing: 20) {
                    Text("What are your interested about?")
                        .multilineTextAlignment(.center)
                        .font(.title).bold()
                        .padding(.top, 20)
                    
                    if displayError {
                        WarningTextComponent(text: "Select 5 interests.")
                            .padding(.bottom, 15)
                    }
                    
                    ScrollView(.horizontal){
                        LazyHStack{
                            ForEach(selectedInterests, id: \.self) { interest in
                                Button {
                                        selectedInterests.removeAll { $0 == interest}
                                } label: {
                                    HStack{
                                        Text(interest)
                                            .selectedTagTextStyle()
                                        Image(systemName: "xmark")
                                    }
                                    .selectedTagCapsuleStyle()
                                }
                            }
                        }
                    }
                    
                    WrappingHStack(alignment: .leading){
                        ForEach(InterestOptions, id: \.name) { interest in
                            Button {
                                if selectedInterests.contains(interest.name) {
                                    selectedInterests.removeAll { $0 == interest.name }
                                } else {
                                    if selectedInterests.count < 5 {
                                        selectedInterests.append(interest.name)
                                    }
                                }
                            } label: {
                                if selectedInterests.contains(interest.name) {
                                    Text(interest.name)
                                        .selectedTagTextStyle()
                                        .selectedTagCapsuleStyle()
                                } else {
                                    Text(interest.name)
                                        .normalTagTextStyle()
                                        .normalTagCapsuleStyle()
                                }
                            }
                        }
                    }
                    
                }
                .padding(.vertical)
            }
            .scrollIndicators(.hidden)
            Spacer()
            
            NavigationLink(destination: RegistrationOccupationView()){
                Text("Next (\(selectedInterests.count)/5)")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .cornerRadius(10)
                    .fontWeight(.semibold)
            }
            .disableWithOpacity(selectedInterests.count < 5)
            .onTapGesture {
                if selectedInterests.count < 5 {
                    displayError.toggle()
                }
            }
        }
        .padding(.horizontal)
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
    RegistartionInterestsView(selectedInterests: .constant(["Hiking"]))
}
