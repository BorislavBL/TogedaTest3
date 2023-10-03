//
//  TagStyle.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation
import SwiftUI

extension View {
    func normalTagCapsuleStyle() -> some View {
        self.frame(height: 16)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background{Capsule().fill(Color("secondaryColor"))}
    }
    
    func selectedTagCapsuleStyle() -> some View {
        self.frame(height: 16)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background{Capsule().fill(Color("SelectedFilter"))}
    }
    
    func normalTagRectangleStyle() -> some View {
        self.padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background{Color("secondaryColor")}
            .cornerRadius(10)
    }
}

extension Text {
    func selectedTagTextStyle() -> some View{
        self.foregroundColor(Color("selectedTextColor"))
            .font(.footnote)
            .fontWeight(.bold)
    }
    
    func normalTagTextStyle() -> some View{
        self.foregroundColor(Color("textColor"))
            .font(.footnote)
            .fontWeight(.bold)
    }
}
