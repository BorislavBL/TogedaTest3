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
    
    @StateObject var imgVM = ImageSaver()
    var body: some View {
        ZStack{
            VStack(){
                HStack(alignment: .center) {
                    Button{isActive = false} label: {
                        Image(systemName: "xmark")
                    }
                    
                    Spacer()
                    
                    Button{
                        Task{
                            await imgVM.writeToPhotoAlbum(image: nil, imageURL: image)
                            
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                            withAnimation {
                                imgVM.hasBeenSaved = false
                            }
                        })
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
            
            if imgVM.hasBeenSaved {
                Text("Saved")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(.gray)
                    .padding()
                    .background(.bar)
                    .cornerRadius(10)
                    .onAppear() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                            withAnimation {
                                imgVM.hasBeenSaved = false
                            }
                        })
                    }
            }
        }
//        .ignoresSafeArea(.container)
    }
}

#Preview {
    ImageViewer(isActive: .constant(true), image: "")
}
