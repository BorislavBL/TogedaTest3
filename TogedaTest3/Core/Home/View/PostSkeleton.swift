//
//  PostSkeleton.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 30.05.24.
//

import SwiftUI

struct PostSkeleton: View {
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 15){
                
                //MARK: - Post Header
                
                HStack(alignment: .center) {
                    
                    Rectangle()
                        .blinking(duration: 0.75)
//                        .skeleton(with: true, shape: .rounded(.radius(15)))
                        .frame(width: 50, height: 50)
                        .cornerRadius(15)
                        
                        VStack(alignment: .leading, spacing: 3){
                            Capsule()
                                .blinking(duration: 0.75)
//                                .skeleton(with: true, shape: .capsule)
                                .frame(width: 200, height: 20)

                            Capsule()
                                .blinking(duration: 0.75)
//                                .skeleton(with: true, shape: .capsule)
                                .frame(width: 100, height: 20)
                        }
                    
                    Spacer()
                    
                    //MARK: - Post Options

                    Rectangle()
                        .blinking(duration: 0.75)
//                        .skeleton(with: true, shape: .rounded(.radius(10)))
                        .frame(width: 25, height: 25)
                        .cornerRadius(10)
                
   
                }
 

                Rectangle()
                    .blinking(duration: 0.75)
//                    .skeleton(with: true, shape: .rounded(.radius(10)))
                    .frame(height: 400)
                    .cornerRadius(10)
                
                //MARK: - Buttons
                
                HStack(alignment: .center, spacing: 20){

                    Rectangle()
                        .blinking(duration: 0.75)
//                        .skeleton(with: true, shape: .rounded(.radius(10)))
                        .frame(width: 25, height: 25)
                        .cornerRadius(10)
                    
                    Rectangle()
                        .blinking(duration: 0.75)
//                        .skeleton(with: true, shape: .rounded(.radius(10)))
                        .frame(width: 25, height: 25)
                        .cornerRadius(10)
                    
                    Rectangle()
                        .blinking(duration: 0.75)
//                        .skeleton(with: true, shape: .rounded(.radius(10)))
                        .frame(width: 25, height: 25)
                        .cornerRadius(10)
                    
                    
                    Spacer()
                    
                    Rectangle()
                        .blinking(duration: 0.75)
//                        .skeleton(with: true, shape: .rounded(.radius(10)))
                        .frame(width: 25, height: 25)
                        .cornerRadius(10)
                    
                }
                .foregroundColor(Color("textColor"))
                
                //MARK: - Tags
                HStack(alignment: .center, spacing: 5) {
                    Capsule()
                        .blinking(duration: 0.75)
//                        .skeleton(with: true, shape: .capsule)
                        .frame(width: 100, height: 30)
                    Capsule()
                        .blinking(duration: 0.75)
//                        .skeleton(with: true, shape: .capsule)
                        .frame(width: 100, height: 30)
                    Capsule()
                        .blinking(duration: 0.75)
//                        .skeleton(with: true, shape: .capsule)
                        .frame(width: 100, height: 30)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color("postCellColor"))
        .cornerRadius(10)
        .padding(.horizontal, 8)
    }
}

#Preview {
    PostSkeleton()
}
