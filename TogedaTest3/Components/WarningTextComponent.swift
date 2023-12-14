//
//  WarrningTextComponent.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 14.12.23.
//

import SwiftUI


struct WarningTextComponent: View {
    var text: String
    var body: some View {
        HStack(alignment: .center){
            Image(systemName: "exclamationmark.circle")
            Text(text)
        }
        .foregroundStyle(.red)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    WarningTextComponent(text: "Lorem Ipsum lorem Ipsum")
}
