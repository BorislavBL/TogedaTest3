//
//  SearchFilters.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 5.10.23.
//

import SwiftUI

struct SearchFilters: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                ForEach(searchFilters, id: \.self) { filter in
                    SearchFilterButton(viewModel: viewModel, filter: filter)
                }
            }
            
        }
        
    }
}

struct SearchFilterButton: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var filter: String
    
    var body: some View {
            Button {
                viewModel.selectedFilter = filter
            } label: {
                if viewModel.selectedFilter == filter {
                    Text(filter)
                        .selectedTagTextStyle()
                        .selectedTagCapsuleStyle()
                } else {
                    Text(filter)
                        .normalTagTextStyle()
                        .normalTagCapsuleStyle()
                        
                }
            }
        }
    }


#Preview {
    SearchFilters(viewModel: HomeViewModel())
}
