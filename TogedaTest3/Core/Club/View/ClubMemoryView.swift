//
//  GroupMemoryView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.01.24.
//

import SwiftUI

struct ClubMemoryView: View {
    @ObservedObject var groupVM: ClubViewModel
    @Binding var showImagesViewer: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text("Memories")
                    .font(.body)
                    .fontWeight(.bold)
                
                Text("\(groupVM.images.count)")
                    .foregroundStyle(.gray)
                
            }
            
            MemoriesTab(images: groupVM.images, selectedImage: $groupVM.selectedImage, showImagesViewer: $showImagesViewer)
            
        }
        .padding(.horizontal)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .padding(.vertical)
        .background(.bar)
        .cornerRadius(10)
    }
}

#Preview {
    ClubMemoryView(groupVM: ClubViewModel(), showImagesViewer: .constant(true))
}
