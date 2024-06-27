//
//  TypeFilters.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 11.12.23.
//

import SwiftUI

struct TypeFilters: View {
    @ObservedObject var filterVM: FilterViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                ForEach(filterVM.types, id: \.self){ type in
                    Button{
                        filterVM.selectedType = type
                    } label:{
                        if type == filterVM.selectedType {
                            Text(type.rawValue)
                                .selectedTagTextStyle()
                                .selectedTagCapsuleStyle()
                        } else {
                            Text(type.rawValue)
                                .normalTagTextStyle()
                                .normalTagCapsuleStyle()
                        }
                    }
                    
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    TypeFilters(filterVM: FilterViewModel())
}
