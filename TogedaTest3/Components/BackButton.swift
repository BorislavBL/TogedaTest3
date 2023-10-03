//
//  BackButton.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct BackButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.backward")
                .foregroundColor(Color("textColor"))
                .frame(width: 40, height: 40)
                .background(.bar)
                .cornerRadius(8.0)
        }
    }
}

struct BackButton_Previews: PreviewProvider {
    static var previews: some View {
        BackButton(action: {print("Button pressed!")})
    }
}
