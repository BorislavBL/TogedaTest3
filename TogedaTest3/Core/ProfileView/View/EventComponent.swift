//
//  EventComponent.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct EventComponent: View {
    
    private let imageDimension: CGFloat = (UIScreen.main.bounds.width / 3) - 18
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image("event_1")
                .resizable()
                .scaledToFill()
                .frame(width: imageDimension, height: imageDimension * 1.3)
                .clipped()
            
            VStack{
                Text("Hiking in the mountain")
                    .font(.footnote)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: imageDimension)
            .frame(height: imageDimension * 0.4)
            .background(Color(.black).opacity(0.3))
        }
        .cornerRadius(20)
    }
}

struct EventComponent_Previews: PreviewProvider {
    static var previews: some View {
        EventComponent()
    }
}
