//
//  NavButtonStyle.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 24.01.24.
//

import SwiftUI

extension View {
    func navButton1() -> some View {
        self.foregroundColor(Color("textColor"))
            .frame(width: 35, height: 35)
            .background(Color("main-secondary-color"))
            .clipShape(Circle())
    }
    
    func navButton2() -> some View {
        self.frame(width: 35, height: 35)
            .background(Color(.tertiarySystemFill))
            .clipShape(Circle())
    }
    
    func navButton3() -> some View {
        self.frame(width: 35, height: 35)
            .background(.bar)
            .clipShape(Circle())
    }
}
