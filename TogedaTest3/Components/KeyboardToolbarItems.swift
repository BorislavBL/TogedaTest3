//
//  KeyboardToolbarItems.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 14.05.24.
//

import SwiftUI

struct KeyboardToolbarItems: View {
    var body: some View {
        HStack{
            Spacer()
            
            Button(){
                hideKeyboard()
            } label:{
                Text("Done")
                    .foregroundStyle(.blue)
                    .bold()
            }
        }
    }
}

#Preview {
    KeyboardToolbarItems()
}
