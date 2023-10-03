//
//  Filters.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//


import SwiftUI

struct Filters: View {
    let allFilters: [Filter] = Filter.FILTERS
    
    @ObservedObject var viewModel: FilterViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                Button {
                    print("all")
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 18)
                        .foregroundColor(Color("textColor"))
                }
                .normalTagCapsuleStyle()
                
                ForEach(viewModel.filters.indices, id: \.self) { index in
                    FilterButton(index: index, viewModel: viewModel)
                }
            }.padding(.horizontal)
            
        }
        
    }
}

struct FilterButton: View {
    @State private var index: Int
    @ObservedObject var viewModel: FilterViewModel
    
    init(index: Int, viewModel: FilterViewModel) {
        self.index = index
        self.viewModel = viewModel
    }
    
    var filter: Filter {
        viewModel.filters[index]
    }
    
    var body: some View {
            Button {
                viewModel.filters[index].isSelected = true
                viewModel.selectedFilter = filter
                viewModel.filterIsSelected = filter.isSelected
                viewModel.selectedFilterIndex = index
            } label: {
                if filter.selectedCategory != "Any" {
                    Text(filter.selectedCategory)
                        .selectedTagTextStyle()
                        .selectedTagCapsuleStyle()
                } else {
                    Text(filter.categoryName)
                        .normalTagTextStyle()
                        .normalTagCapsuleStyle()
                        
                }
            }
        }
    }

struct Filters_Previews: PreviewProvider {
    static var previews: some View {
        Filters(viewModel: FilterViewModel())
    }
}

