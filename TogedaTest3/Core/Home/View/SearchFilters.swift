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
                SearchFilterButton(viewModel: viewModel, filter: .events)
                SearchFilterButton(viewModel: viewModel, filter: .users)
                SearchFilterButton(viewModel: viewModel, filter: .clubs)
            }
            
        }
        
    }
}

struct SearchFilterButton: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var filter: SearchCases
    
    var body: some View {
            Button {
                viewModel.selectedFilter = filter
            } label: {
                if viewModel.selectedFilter == filter {
                    Text(filter.toString)
                        .selectedTagTextStyle()
                        .selectedTagCapsuleStyle()
                } else {
                    Text(filter.toString)
                        .normalTagTextStyle()
                        .normalTagCapsuleStyle()
                        
                }
            }
        }
    }


#Preview {
    SearchFilters(viewModel: HomeViewModel())
}
