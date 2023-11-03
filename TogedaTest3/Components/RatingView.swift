//
//  RatingView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 2.11.23.
//

import SwiftUI

struct RatingView: View {
    @Binding var rating: Int
    
    var label = ""
    var maximumRating = 5
    
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    
    var offColor = Color.gray
    var onColor = Color.black
    
    var body: some View {
        HStack(spacing: 2){
            if label.isEmpty == false {
                Text(label)
            }
            
            ForEach(1..<maximumRating + 1, id:\.self){number in
                image(for: number)
                    .foregroundStyle(number > rating ? offColor : onColor)
            }
        }
    }
    
    func image(for number: Int) -> Image {
        if number > rating {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
}

#Preview {
    RatingView(rating: .constant(4))
}
