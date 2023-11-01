//
//  MemoriesTab.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 1.11.23.
//

import SwiftUI

struct MemoriesTab: View {
    @State var images: [String]
    @Binding var selectedImage: Int
    @Binding var showImagesViewer: Bool
    var body: some View {
        VStack{
            HStack {
                Group{
                    Button{
                        selectedImage = 0
                        showImagesViewer = true
                    } label: {
                        Image(images[0])
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .frame(minWidth: 0)
                            .cornerRadius(10)
                            .clipped()
                    }
                    if images.count == 2 {
                        Button{
                            selectedImage = 1
                            showImagesViewer = true
                        } label: {
                            Image(images[1])
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .frame(minWidth: 0)
                                .cornerRadius(10)
                                .clipped()
                        }
                    }
                }
            }
            if images.count > 2{
                HStack {
                    Button{
                        selectedImage = 1
                        showImagesViewer = true
                    } label: {
                        Image(images[1])
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .frame(minWidth: 0)
                            .cornerRadius(10)
                            .clipped()
                    }
                    
                    Button{
                        selectedImage = 2
                        showImagesViewer = true
                    } label: {
                        Image(images[2])
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .cornerRadius(10)
                            .clipped()
                    }
                    
                    if images.count == 4 {
                        ZStack{
                            Button{
                                selectedImage = 3
                                showImagesViewer = true
                            } label: {
                                Image(images[3])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .frame(minWidth: 0)
                                    .cornerRadius(10)
                                    .clipped()
                                
                                
                                if images.count > 4 {
                                    Rectangle()
                                        .foregroundStyle(.black.opacity(0.5))
                                        .frame(height: 200)
                                        .frame(minWidth: 0)
                                        .cornerRadius(10)
                                    Text("+\(images.count - 4) >")
                                        .foregroundStyle(.white)
                                        .fontWeight(.bold)
                                        .font(.title2)
                                }
                            }
                        }

                    }
                }
            }
        }
    }
}

#Preview {
    MemoriesTab(images: ["event_1", "event_2", "event_3", "event_4"], selectedImage: .constant(0), showImagesViewer: .constant(true))
}
