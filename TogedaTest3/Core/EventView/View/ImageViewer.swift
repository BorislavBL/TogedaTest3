//
//  ImageViewer.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 1.11.23.
//

import SwiftUI

struct ImageViewer: View {
    @Environment(\.dismiss) private var dismiss
    @State var images: [String]
    @State var selectedImage: Int = 0
    
    @State var scale = 1.0
    
    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { state in
                withAnimation(.snappy) {
                    scale = state
                }
            }
            .onEnded { state in
                withAnimation(.snappy) {
                    scale = 1.0
                }
            }
    }
    
    var body: some View {
        NavigationView{
        TabView(selection: $selectedImage){
            ForEach(images.indices, id: \.self){ index in
                Image(images[index])
                    .resizable()
                    .scaledToFit()
                    .tag(index)
                    .scaleEffect(scale)
                    .gesture(magnification)
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
    ImageViewer(images: ["event_1", "event_2", "event_3", "event_4"])
}
