//
//  CustomNavBar.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct CustomNavBar: View {
    @Binding var showFilter: Bool
    @ObservedObject var filterVM: FilterViewModel
    @EnvironmentObject var postViewModel: PostsViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @ObservedObject var homeViewModel: HomeViewModel
    @Binding var showLocationServicesView: Bool
    
    var body: some View {
        VStack{
            if !homeViewModel.showCancelButton{
                HStack(spacing: 12){
                    Text("Togeda")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("blackAndWhite"))
                    
                    Spacer(minLength: 0)
                    
                    Group{
                    
                        if !showLocationServicesView {
                            Button{
                                withAnimation{
                                    filterVM.showAllFilter = true
                                }
                            } label:{
                                Image(systemName: "slider.horizontal.3")
                                
                            }
                        }
                        
                        Button{
                            withAnimation{
                                homeViewModel.showCancelButton = true
                            }
                        } label:{
                            Image(systemName: "magnifyingglass")
                        }
                        
                        
                        NavigationLink(value: SelectionPath.notification) {
                            Image(systemName: "bell")
                        }
                        
                    }
                    .navButton1()
                    
                }
                .padding(.horizontal)
                
                if showFilter && !showLocationServicesView {
//                    Filters(viewModel: viewModel)
                    TypeFilters(filterVM: filterVM)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            } else {
                VStack(alignment: .leading, spacing:8){
                    CustomSearchBar(searchText: $homeViewModel.searchText, showCancelButton: $homeViewModel.showCancelButton)
                    
                    SearchFilters(viewModel: homeViewModel)
                    
                }
                .padding(.top, 8)
                .padding(.horizontal)
            }

            Divider()
        }
        .background(.bar)
    }
    
}



struct CustomNavBar_Previews: PreviewProvider {
    @State static var showFilterPreview = true
    static var previews: some View {
        CustomNavBar(showFilter: $showFilterPreview, filterVM: FilterViewModel(), homeViewModel: HomeViewModel(), showLocationServicesView: .constant(false))
            .environmentObject(PostsViewModel())
            .environmentObject(UserViewModel())
    }
}
