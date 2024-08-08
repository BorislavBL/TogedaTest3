//
//  LoadingScreenView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 8.07.24.
//

import SwiftUI

struct LoadingScreenView: View {
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack(alignment: .center){
            ProgressView()
                .scaleEffect(2)
                .frame(width: 120, height: 120, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .background(.bar)
                .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .background(.black.opacity(0.2))
        .opacity(isVisible ? 1 : 0)
    }
}

#Preview {
    LoadingScreenView(isVisible: .constant(true))
}
