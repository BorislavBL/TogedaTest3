//
//  Test2View.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.11.23.
//

import SwiftUI

struct Test2View: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack{
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .imageScale(.medium)
                .padding(.all, 8)
                .background(Color("secondaryColor"))
                .clipShape(Circle())
        }
        )
    }
}

#Preview {
    Test2View()
}
