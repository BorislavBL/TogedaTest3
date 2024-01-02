//
//  GroupComponent.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 2.01.24.
//

import SwiftUI
import WrappingHStack

struct GroupComponent: View {
    var userID: String
    let size: CGSize = CGSize(width: (UIScreen.main.bounds.width / 2) - 16, height: ((UIScreen.main.bounds.width / 2) - 16) * 1.5)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image("event_1")
                .resizable()
                .scaledToFill()
                .frame(size)
                .clipped()
            
            LinearGradient(gradient: Gradient(colors: [.black.opacity(0), .black.opacity(0), .black]), startPoint: .top, endPoint: .bottom)
                .opacity(0.95)
            
            VStack(alignment: .leading){
                
                    Text("Hosted")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("lightGray"))
                        .padding(.bottom, 2)
                
                
                Text("Skydiving club Sofia")
                    .font(.footnote)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .padding(.bottom, 5)
                
                WrappingHStack(alignment: .leading, verticalSpacing: 5){
                    
                    HStack{
                        Image(systemName: "eye")
                            .font(.caption)
                            .foregroundColor(Color("lightGray"))
                        
                        Text("Public")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("lightGray"))
                    }
                    
                    HStack{
                        Image(systemName: "person.3.fill")
                            .font(.caption)
                            .foregroundColor(Color("lightGray"))
                        
                        Text("100k")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("lightGray"))
                    }
                    
                }
                .padding(.bottom, 2)

                
                HStack(alignment: .center){
                    
                    Image(systemName: "location")
                        .font(.caption)
                        .foregroundColor(Color("lightGray"))
                    
                    Text("Sofia, Bulgaria")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("lightGray"))
                    
                }
            }
            
            .padding(.horizontal, 12)
            .padding(.vertical)
            .frame(maxWidth: size.width, maxHeight: size.height, alignment: .bottomLeading)
//            .background {
//                TransparentBlurView(removeAllFilters: true)
//                    .blur(radius: 2, opaque: true)
//                    .background(.black.opacity(0.35))
//            }
 
        }
        .frame(size)
        .cornerRadius(20)
    }
}

#Preview {
    GroupComponent(userID: User.MOCK_USERS[0].id)
}
