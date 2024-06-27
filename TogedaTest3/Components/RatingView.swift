//
//  RatingView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 2.11.23.
//

import SwiftUI

struct RatingView: View {
    var rating: Int
    
    var label = ""
    var maximumRating = 5
    
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    
    var offColor = Color.gray
    var onColor = Color("blackAndWhite")
    
    var dimension: CGFloat = 16
    var spacing: CGFloat = 2
    
    var body: some View {
        HStack(spacing: spacing){
            if label.isEmpty == false {
                Text(label)
            }
            
            ForEach(1..<maximumRating + 1, id:\.self){number in
                image(for: number)
                    .resizable()
                    .scaledToFit()
                    .frame(width: dimension, height: dimension)
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
    RatingView(rating: 4)
}
