//
//  RatingButtonView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.11.23.
//

import SwiftUI

struct RatingButtonView: View {
    @Binding var rating: Int
    
    var label = ""
    var maximumRating = 5
    
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    
    var offColor = Color.gray
    var onColor = Color.black
    
    var dimension: CGFloat = 16
    var spacing: CGFloat = 2
    
    var body: some View {
        HStack(spacing: spacing){
            if label.isEmpty == false {
                Text(label)
            }
            
            ForEach(1..<maximumRating + 1, id:\.self){number in
                Button{
                    rating = number
                } label:{
                    image(for: number)
                        .resizable()
                        .scaledToFit()
                        .frame(width: dimension, height: dimension)
                        .foregroundStyle(number > rating ? offColor : onColor)
                }
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
    RatingButtonView(rating: .constant(4))
}
