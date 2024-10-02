//
//  StrokeText.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 1.10.24.
//

import SwiftUI

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:  width, y:  width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y:  width)
                Text(text).offset(x:  width, y: -width)
            }
            .foregroundColor(color)
            Text(text)
        }
    }
}

#Preview {
    StrokeText(text: "Test", width: 0.5, color: .red)
}
