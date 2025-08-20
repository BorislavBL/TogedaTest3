//
//  InterestsWrapper.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 7.08.25.
//

import SwiftUI
import WrappingHStack

struct InterestsWrapper: View {
    @EnvironmentObject private var userVM: UserViewModel
    @Environment(\.colorScheme) var scheme
    var interests: [Components.Schemas.Interest]
    
    var body: some View {
        VStack{
//            WrappingHStack(alignment: .leading) {
//                ForEach(interests, id: \.self) { interest in
//                    let isSelected = userVM.currentUser?.interests.contains(where: { $0.name == interest.name }) ?? false
//                    
//                    if isSelected {
//                        Text("\(interest.icon) \(interest.name)")
//                            .selectedTagTextStyle()
//                            .selectedTagCapsuleStyle()
//                    } else {
//                        Text("\(interest.icon) \(interest.name)")
//                            .normalTagTextStyle()
//                            .normalTagCapsuleStyle()
//                    }
//                }
//            }
            
            WrappingHStack(alignment: .leading) {
                ForEach(interests, id: \.self) { interest in
                    let isSelected = userVM.currentUser?.interests.contains(where: { $0.name == interest.name }) ?? false
                    
                    if isSelected {
                        Text("\(interest.icon) \(interest.name)")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(Color("testColor"))
                            .frame(height: 16)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background{Capsule().fill(scheme == .dark ? Color(red: 0.9, green: 0.9, blue: 0.9) : Color("SelectedFilter"))}
                    } else {
                        Text("\(interest.icon) \(interest.name)")
                            .normalTagTextStyle()
                            .normalTagCapsuleStyle()
                    }
                }
            }
            
//            WrappingHStack(alignment: .leading) {
//                ForEach(interests, id: \.self) { interest in
//                    let isSelected = userVM.currentUser?.interests.contains(where: { $0.name == interest.name }) ?? false
//                    
//                    if isSelected {
//                        Text("\(interest.icon) \(interest.name)")
//                            .selectedTagTextStyle()
//                            .frame(height: 16)
//                            .padding(.horizontal, 10)
//                            .padding(.vertical, 8)
//                            .background{Capsule().fill(interestColor(for: interest.category).opacity(0.8))}
//                    } else {
//                        Text("\(interest.icon) \(interest.name)")
//                            .normalTagTextStyle()
//                            .frame(height: 16)
//                            .padding(.horizontal, 10)
//                            .padding(.vertical, 8)
//                            .background{Capsule().fill(interestColor(for: interest.category).opacity(0.3))}
//                    }
//                }
//            }
        }
    }
}

#Preview {
    InterestsWrapper(interests: [])
        .environmentObject(UserViewModel())
}
