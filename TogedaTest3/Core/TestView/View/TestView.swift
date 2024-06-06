//
//  CreateEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct TestView: View {

    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            Color(.systemGray5)
                .frame(height: 200)
                .cornerRadius(8)
            
            LinearGradient(gradient: Gradient(colors: [Color(.systemGray5).opacity(0.6), Color(.systemGray5).opacity(0.3), Color(.systemGray5).opacity(0.6)]),
                           startPoint: .leading,
                           endPoint: .trailing)
                .frame(height: 200)
                .cornerRadius(8)
                .offset(x: animateGradient ? 300 : -300)
                .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false))
                .onAppear {
                    self.animateGradient.toggle()
                }
        }
        .padding()
    }
    
  }



struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

