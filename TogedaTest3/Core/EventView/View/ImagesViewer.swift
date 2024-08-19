//
//  ImageViewer.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 1.11.23.
//

import SwiftUI

struct ImagesViewer: View {
    @Environment(\.dismiss) private var dismiss
    @State var images: [String]
    @Binding var selectedImage: Int

    
    var body: some View {
        NavigationView{
        TabView(selection: $selectedImage){
            ForEach(images.indices, id: \.self){ index in
                Image(images[index])
                    .resizable()
                    .scaledToFit()
                    .tag(index)
                    .pinchToZoom()
            }
        }
        .background(.black)
        .tabViewStyle(.page)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .foregroundStyle(.white)
        })
    }
    }
    
}

#Preview {
    ImagesViewer(images: ["event_1", "event_2", "event_3", "event_4"], selectedImage: .constant(0))
}
