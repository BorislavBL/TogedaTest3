//
//  InboxSkeleton.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.05.25.
//

import SwiftUI

struct InboxSkeleton: View {
    var size: ImageSize = .medium

    var body: some View {
        ScrollView{
            ForEach(0..<25){ _ in
                SkeletonRow()
            }
        }
        .background(.bar)

    }
    
    func SkeletonRow() -> some View {
        HStack(alignment: .center) {
            
            Circle()
                .blinking(duration: 0.75)
                .frame(width: size.dimension, height: size.dimension)
            
            VStack(alignment: .leading, spacing: 3){
                Capsule()
                    .blinking(duration: 0.75)
                    .frame(width: 200, height: 20)
                
                Capsule()
                    .blinking(duration: 0.75)
                    .frame(width: 100, height: 20)
            }
            
            
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .cornerRadius(10)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}



#Preview {
    InboxSkeleton()
}
