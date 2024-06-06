//
//  PostSkeleton.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 30.05.24.
//

import SwiftUI
import SkeletonUI

struct PostSkeleton: View {
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 15){
                
                //MARK: - Post Header
                
                HStack(alignment: .center) {
                    
                    Rectangle()
                        .skeleton(with: true, shape: .rounded(.radius(15)))
                        .frame(width: 50, height: 50)
                        
                        VStack(alignment: .leading, spacing: 3){
                            Rectangle()
                                .skeleton(with: true, shape: .capsule)
                                .frame(width: 200, height: 20)

                            Rectangle()
                                .skeleton(with: true, shape: .capsule)
                                .frame(width: 100, height: 20)
                        }
                    
                    Spacer()
                    
                    //MARK: - Post Options

                    Rectangle()
                        .skeleton(with: true, shape: .rounded(.radius(10)))
                        .frame(width: 25, height: 25)
                
   
                }
 

                Rectangle()
                    .skeleton(with: true, shape: .rounded(.radius(10)))
                    .frame(height: 400)
                
                //MARK: - Buttons
                
                HStack(alignment: .center, spacing: 20){

                    Rectangle()
                        .skeleton(with: true, shape: .rounded(.radius(10)))
                        .frame(width: 25, height: 25)
                    
                    Rectangle()
                        .skeleton(with: true, shape: .rounded(.radius(10)))
                        .frame(width: 25, height: 25)
                    
                    Rectangle()
                        .skeleton(with: true, shape: .rounded(.radius(10)))
                        .frame(width: 25, height: 25)
                    
                    
                    Spacer()
                    
                    Rectangle()
                        .skeleton(with: true, shape: .rounded(.radius(10)))
                        .frame(width: 25, height: 25)
                    
                }
                .foregroundColor(Color("textColor"))
                
                //MARK: - Tags
                HStack(alignment: .center, spacing: 5) {
                    Capsule()
                        .skeleton(with: true, shape: .capsule)
                        .frame(width: 100, height: 30)
                    Capsule()
                        .skeleton(with: true, shape: .capsule)
                        .frame(width: 100, height: 30)
                    Capsule()
                        .skeleton(with: true, shape: .capsule)
                        .frame(width: 100, height: 30)
                }
//                .frame(maxWidth: UIScreen.main.bounds.width - 24, alignment: .leading)
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
