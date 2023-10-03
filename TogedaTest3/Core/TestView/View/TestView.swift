//
//  TestView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct TestView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
          Text("Searching for \(searchText)")
          .searchable(text: $searchText, prompt: "Look for something")
          .foregroundColor(.red)
          .navigationTitle("Searchable Example")
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

