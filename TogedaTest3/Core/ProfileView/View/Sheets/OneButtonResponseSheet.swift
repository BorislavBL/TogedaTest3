//
//  OneButtonResponseSheet.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 7.06.24.
//

import SwiftUI

struct OneButtonResponseSheet: View {
    var onClick: () -> ()
    var buttonText: String
    var image: Image
    var body: some View {
        VStack(alignment: .leading){
            Button{
                onClick()
            } label: {
                HStack{
                    Text(buttonText)
                        .fontWeight(.semibold)
                        .normalTagTextStyle()
                    
                    Spacer()
                    
                    image
                        .frame(width: 35, height: 35)
                        .foregroundColor(Color("textColor"))
                    

                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background{Color("main-secondary-color")}
                .cornerRadius(10)
            }
        }
        .padding()
    }
}

#Preview {
    OneButtonResponseSheet(onClick: {}, buttonText: "Some text here", image: Image(systemName: "x.circle.fill"))
}
