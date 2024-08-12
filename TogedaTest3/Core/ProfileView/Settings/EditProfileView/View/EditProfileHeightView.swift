//
//  EditProfileHeightView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.04.24.
//

import SwiftUI

struct EditProfileHeightView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var heightText: String
    
    var body: some View {
        AutoSizeSheetView{
            VStack(alignment: .leading, spacing: 30){
                HStack{
                    Spacer()
                    Button{
                        dismiss()
                    } label:{
                        Image(systemName: "xmark")
                            .frame(width: 35, height: 35)
                            .background(Color("main-secondary-color"))
                            .clipShape(Circle())
                    }
                }
                
                Text("How tall are you?")
                    .font(.title3)
                    .bold()
                
                HStack {
                    TextField("", text: $heightText)
                        .placeholder(when: heightText.isEmpty) {
                            Text("100")
                                .foregroundColor(.secondary)
                                .bold()
                        }
                        .bold()
                        .autocapitalization(.none)
                        .keyboardType(.numberPad)
                        .onChange(of: heightText) { old, new in
                            if let number = Int(heightText) {
                                if number > 300 {
                                    heightText = old
                                }
                            }
                        }
                    
                    Text("cm (\(convertCmToFeetAndInches(heightText) ?? "feet"))")
                }
                .createEventTabStyle()
                
            }
        }

    }
}

#Preview {
    EditProfileHeightView(heightText: .constant("100"))
}
