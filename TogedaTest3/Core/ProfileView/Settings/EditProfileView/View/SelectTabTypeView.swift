//
//  SelectTabTypeView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 22.12.23.
//

import SwiftUI
import WrappingHStack

struct SelectTabTypeView: View {
    var image: Image
    var title: String
    var types: [String]
    @State private var selectedType: String = ""
    @ObservedObject var editProfileVM: EditProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var sheetHeight: CGFloat = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30){
            HStack{
                Spacer()
                Button{dismiss()} label:{
                    Image(systemName: "xmark")
                        .frame(width: 35, height: 35)
                        .background(Color("main-secondary-color"))
                        .clipShape(Circle())
                }
            }
            HStack{
                image
                    .font(.title3)
                Text(title)
                    .font(.title3)
                    .bold()
            }
            WrappingHStack(alignment: .leading){
                ForEach(types, id: \.self) { type in
                    Button {
                        if type == selectedType {
                            switch editProfileVM.selectedType {
                            case .workout:
                                editProfileVM.editUser.details?.workout = ""
                            case .education:
                                editProfileVM.editUser.details?.education = ""
                            case .personalityType:
                                editProfileVM.editUser.details?.personalityType = ""
                            }
                            selectedType = ""
                        } else {
                            switch editProfileVM.selectedType {
                            case .workout:
                                editProfileVM.editUser.details?.workout = type
                            case .education:
                                editProfileVM.editUser.details?.education = type
                            case .personalityType:
                                editProfileVM.editUser.details?.personalityType = type
                            }
                            selectedType = type
                        }
                    } label: {
                        if type == selectedType {
                            Text(type)
                                .selectedTagTextStyle()
                                .selectedTagCapsuleStyle()
                        } else {
                            Text(type)
                                .normalTagTextStyle()
                                .normalTagCapsuleStyle()
                        }
                    }
                }
            }
        }
        .onAppear(){
            switch editProfileVM.selectedType {
            case .workout:
                selectedType = editProfileVM.editUser.details?.workout ?? ""
            case .education:
                selectedType =  editProfileVM.editUser.details?.education ?? ""
            case .personalityType:
                selectedType = editProfileVM.editUser.details?.personalityType ?? ""
            }
        }
        .padding()
        .overlay {
            GeometryReader { geometry in
                Color.clear.preference(key: InnerHeightPreferenceKey.self, value: geometry.size.height)
            }
        }
        .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
            sheetHeight = newHeight
        }
        .presentationDetents([.height(sheetHeight + 20)])

    }
}

struct InnerHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    SelectTabTypeView(image: Image(systemName: "dumbbell"), title: "How often do you workout?123456789098765432345678987654", types: ["everyday", "most days", "often", "sometimes", "never" ], editProfileVM: EditProfileViewModel())
}
