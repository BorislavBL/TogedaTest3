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
                    if text.count > 500 {
                        text = String(text.prefix(500))
                    }
                }
            
            Text("\(500 - text.count)")
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
        }
        .padding()
        .background(Color("secondaryColor"))
        .cornerRadius(10)
    }
}

#Preview {
    EditProfileBioView(text: .constant(""), placeholder: "Bio")
}
