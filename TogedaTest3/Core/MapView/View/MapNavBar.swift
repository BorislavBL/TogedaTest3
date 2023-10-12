//
//  MapNavBar.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 4.10.23.
//

import SwiftUI

struct MapNavBar: View {
    @Binding var searchText: String
    @Binding var showSearch: Bool
    @ObservedObject var viewModel: FilterViewModel
    
    
    var body: some View {
        VStack(){
            CustomSearchBar(searchText: $searchText, showCancelButton: $showSearch)
                .padding(.vertical, 8)
                .padding(.horizontal)
            Filters(viewModel: viewModel)
                .transition(.move(edge: .top).combined(with: .opacity))
            Divider()
        }
        .background(.bar)
    }
}

#Preview {
    MapNavBar(searchText: .constant(""), showSearch: .constant(false), viewModel: FilterViewModel())
}
