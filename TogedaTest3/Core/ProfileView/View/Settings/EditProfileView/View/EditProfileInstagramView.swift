//
//  EditProfileInstagramView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 22.12.23.
//

import SwiftUI

struct EditProfileInstagramView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var instaText: String
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
            
            Text("What's your Instagram?")
                .font(.title3)
                .bold()
            
            TextField("", text: $instaText)
                .placeholder(when: instaText.isEmpty) {
                    Text("@username")
                        .foregroundColor(.secondary)
                        .bold()
                }
                .bold()
                .autocapitalization(.none)
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
    EditProfileInstagramView(instaText: .constant(""))
}
