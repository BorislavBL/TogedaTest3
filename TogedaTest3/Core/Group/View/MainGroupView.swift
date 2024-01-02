//
//  MainGroupView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 2.01.24.
//

import SwiftUI

struct MainGroupView: View {
    var body: some View {
        VStack(alignment: .center) {
            
            TabView {
                ForEach(["event_1", "event_2"], id: \.self) { image in
                    
                    Image(image)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                    
                    
                }
                
            }
            .tabViewStyle(PageTabViewStyle())
            .cornerRadius(10)
            .frame(height: 400)
            
            
            
            
            VStack(spacing: 10) {
                Text("Sky Diving Club Sofia")
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 5){
                    Image(systemName: "suitcase")
                    
                    Text("Graphic Designer")
                        .font(.footnote)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.gray)
                
                HStack(spacing: 5){
                    Image(systemName: "mappin.circle")
                    
                    Text("Sofia Bulgaria")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
                .foregroundColor(.gray)
                
                
            }.padding(.vertical)
        }
    }
}

#Preview {
    MainGroupView()
}
