//
//  TestView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct TestView: View {
    @State private var searchText = ""
    @State var showSearch = false
    
    var body: some View {
        NavigationView {
            VStack{
                CustomSearchBar(searchText: $searchText, showCancelButton: $showSearch)
                Text("Searching for \(searchText)")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .navigationTitle("Searchable Example")
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

