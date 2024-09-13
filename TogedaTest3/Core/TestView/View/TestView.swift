//
//  CreateEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        VStack{
            Text("something [https://stackoverflow.com](https://stackoverflow.com/questions/57744392/how-to-make-hyperlinks-in-swiftui)")
                .tint(.blue)
        }
    }
    
}



struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

