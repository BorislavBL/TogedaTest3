//
//  EditProfileBioView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 20.12.23.
//

import SwiftUI

struct EditProfileBioView: View {
    @Binding var text: String
    var placeholder: String
    var body: some View {
        VStack(alignment:.trailing){
            TextField(placeholder, text: $text, axis: .vertical)
                .fontWeight(.semibold)
                .lineLimit(5, reservesSpace: true)
                .onChange(of: text) { oldValue, newValue in
                    if text.count > 5000 {
                        text = String(text.prefix(5000))
                    }
                }
            
            Text("\(5000 - text.count)")
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
        }
        .padding()
        .background(Color("main-secondary-color"))
        .cornerRadius(10)
    }
}

#Preview {
    EditProfileBioView(text: .constant(""), placeholder: "Bio")
}
