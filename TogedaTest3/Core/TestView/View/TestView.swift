//
//  CreateEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import MapKit

struct TestView: View {
    
    var body: some View {
        VStack{
            NavigationLink(destination: Test2View()) {
                Text("click")
            }
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}


