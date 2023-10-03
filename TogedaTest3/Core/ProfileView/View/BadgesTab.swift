//
//  BadgesTab.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct BadgesTab: View {
    
    private let adaptiveColums = [
        GridItem(.adaptive(minimum: 80))
    ]
    
    var body: some View {
        VStack (alignment: .leading) {
            Text("Badges")
                .font(.body)
                .fontWeight(.bold)
            LazyVGrid(columns: adaptiveColums, spacing: 10){
                ForEach(0..<30, id: \.self){index in
                    Button {
                        print("clicked")
                    } label: {
                        Image("event_2")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .background(.gray)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding()
        .background(.bar)
        .cornerRadius(30)
    }
}

struct BadgesTab_Previews: PreviewProvider {
    static var previews: some View {
        BadgesTab()
    }
}
