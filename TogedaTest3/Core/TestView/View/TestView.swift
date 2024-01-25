//
//  CreateEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct TestView: View {
    let link = URL(string: "https://www.hackingwithswift.com")!
    
    var body: some View {
        VStack{
            ShareLink("", item: link)
            ShareLink("Learn Swift here", item: link)
            ShareLink(item: link) {
                Label("Learn Swift here", systemImage: "swift")
            }
        }
    }
}



struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}


