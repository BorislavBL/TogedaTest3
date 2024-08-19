//
//  ImageViewer.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 19.08.24.
//

import SwiftUI
import Kingfisher

struct ImageViewer: View {
    @Binding var isActive: Bool
    var image: String
    var body: some View {
        VStack(){
            HStack(alignment: .center) {
                Button{isActive = false} label: {
                    Image(systemName: "xmark")
                }
                
                Spacer()
                
                Button{
                    Task{
                        await ImageSaver().writeToPhotoAlbum(image: nil, imageURL: image)
                    }
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
            }
            .padding()
            
            Spacer()
            
            KFImage(URL(string: image))
                .resizable()
                .scaledToFit()
                .pinchToZoom()
            
            Spacer()
        }
        .background(.bar)
//        .ignoresSafeArea(.container)
    }
}

#Preview {
    ImageViewer(isActive: .constant(true), image: "")
}
