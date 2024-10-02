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
    
    var body: some View {
        VStack(){
            HStack{
                CustomSearchBar(searchText: $searchText, showCancelButton: $showSearch)
                
//                if !showSearch {
//                    Button{
//                        withAnimation{
//                            viewModel.showAllFilter = true
//                        }
//                    } label:{
//                        Image(systemName: "slider.horizontal.3")
//                            .foregroundColor(Color("textColor"))
//                            .frame(width: 35, height: 35)
//                            .background(Color(.tertiarySystemFill))
//                            .clipShape(Circle())
//                        
//                    }
//                }

            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            
            
            Divider()
        }
        .background(.bar)
    }
}

#Preview {
    MapNavBar(searchText: .constant(""), showSearch: .constant(false))
}
