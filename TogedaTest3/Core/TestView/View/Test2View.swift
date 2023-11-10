//
//  Test2View.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.11.23.
//

import SwiftUI

struct Test2View: View {
    let maxImageSize: CGFloat = 240
    let minImageSize: CGFloat = 60
    @State private var MinY: CGFloat = 0
    @State private var iMinY: CGFloat = 0
    @State private var showFilter: Bool = true
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .center){
                    VStack(alignment: .center){
                        Text("\(MinY)")
                        if showFilter {
                            TabView {
                                ForEach(0..<5, id: \.self) { image in

                                        Image("event_1")
                                            .resizable()
                                            .scaledToFill()
                                            .clipped()
                                    
                                    
                                }
                                
                            }
                            .tabViewStyle(PageTabViewStyle())
                            .cornerRadius(10)
                            .frame(height: 400)
                        } else {
                            Image("event_1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                        }
                    }
            }
            .padding(.top, 59)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .frame(width: 0, height: 0)
                        .onAppear(){
                            iMinY = geo.frame(in: .global).minY
                        }
                        .onChange(of: geo.frame(in: .global).minY) { oldMinY,  newMinY in
                            MinY = newMinY
                            if newMinY > 0 {
                                showFilter = true
                            } else if newMinY < -55 {
                                showFilter = false
                            }
                        }
                }
            )
        }
        .edgesIgnoringSafeArea(.top)
        
    }
    
    func scaleForImage(geometry: GeometryProxy) -> CGFloat {
        let offset = geometry.frame(in: .global).minY
        let size = max(minImageSize, maxImageSize - offset)
        return size / maxImageSize
    }
    
    func sizeForImage(geometry: GeometryProxy) -> CGFloat {
        let offset = geometry.frame(in: .global).minY
        return max(minImageSize, maxImageSize - offset)
    }
}

#Preview {
    Test2View()
}
