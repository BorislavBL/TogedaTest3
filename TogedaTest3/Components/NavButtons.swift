//
//  NavButtons.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 24.01.24.
//

import SwiftUI

struct NavButtons: View {
    var body: some View {
        VStack{
            //Registration
            Image(systemName: "chevron.left")
                .frame(width: 35, height: 35)
                .background(Color(.tertiarySystemFill))
                .clipShape(Circle())
            
            //Home
            Image(systemName: "chevron.left")
                .foregroundColor(Color("textColor"))
//                    .padding(8)
                .frame(width: 35, height: 35)
                .background(Color("main-secondary-color"))
                .clipShape(Circle())
            
            //Event
            
            Image(systemName: "chevron.left")
                .frame(width: 35, height: 35)
                .background(.bar)
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
        }
    }
}

#Preview {
    NavButtons()
}
