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
    @State private var sheetHeight: CGFloat = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30){
            HStack{
                Spacer()
                Button{
                    dismiss()
                } label:{
                    Image(systemName: "xmark")
                        .frame(width: 35, height: 35)
                        .background(Color("secondaryColor"))
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
                
                Text("cm (\(convertCmToFeetAndInches(heightText) ?? "feet"))")
            }
            .createEventTabStyle()
            
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

#Preview {
    EditProfileHeightView(heightText: .constant("100"))
}
