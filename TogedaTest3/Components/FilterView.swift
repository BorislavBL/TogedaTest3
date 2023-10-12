//
//  FilterView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 4.10.23.
//

import SwiftUI

struct FilterView: View {
    @ObservedObject var filterViewModel: FilterViewModel
    
    var body: some View {
        if let options = filterViewModel.selectedFilter?.options{
            VStack(spacing: 20){
                List{
                    Section{
                        ForEach(options) { option in
                            Button {
                                print(option.name)
                                filterViewModel.filters[filterViewModel.selectedFilterIndex].selectingCategory = option.name
                            } label: {
                                HStack{
                                    Text(option.name)
                                    
                                    Spacer()
                                    
                                    if(option.name == filterViewModel.filters[filterViewModel.selectedFilterIndex].selectingCategory){
                                        Image(systemName: "checkmark")
                                    }
                                    
                                }
                                
                            }                                }
                        
                    } footer: {
                        Button {
                            print("Done")
                            filterViewModel.filters[filterViewModel.selectedFilterIndex].selectedCategory = filterViewModel.filters[filterViewModel.selectedFilterIndex].selectingCategory
                            filterViewModel.filterIsSelected = false
                        } label: {
                            Text("Submit")
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("blackAndWhite"))
                                .foregroundColor(Color("testColor"))
                                .fontWeight(.semibold)
                            
                        }
                        .cornerRadius(10)
                        .padding(.top)
                    }
                    
                }
                
            }
            .presentationDetents([.fraction(0.9)])
            .presentationDragIndicator(.visible)
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

#Preview {
    FilterView(filterViewModel: FilterViewModel())
}
