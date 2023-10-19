//
//  BadgesTab.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct BadgesTab: View {
    var body: some View {
        VStack (alignment: .leading) {
            HStack{
                Text("Badges")
                    .font(.body)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button{
                    
                } label: {
                    Text("View All")
                        .font(.body)
                        .foregroundStyle(.blue)
                }
            }
            .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false){
                LazyHStack{
                    ForEach(0..<30, id: \.self){index in
                        Button {
                            print("clicked")
                        } label: {
                            Image("event_2")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .background(.gray)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.leading)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(.vertical)
        .background(.bar)
        .cornerRadius(10)
    }
}

struct BadgesTab_Previews: PreviewProvider {
    static var previews: some View {
        BadgesTab()
    }
}
