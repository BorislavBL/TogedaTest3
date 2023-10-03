//
//  CustomNavBar.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct CustomNavBar: View {
    @Binding var showFilter: Bool
    
    @ObservedObject var viewModel: FilterViewModel
    @ObservedObject var postViewModel: PostsViewModel
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack{
            HStack(spacing: 12){
                Text("Togeda")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("blackAndWhite"))
                
                Spacer(minLength: 0)
                
                Group{
                    
                    NavigationLink(destination: SearchView(postViewModel: postViewModel, userViewModel: userViewModel)
                        .toolbar(.hidden, for: .tabBar)
                    ) {
                        Image(systemName: "magnifyingglass")
                    }
                    
                    
                    NavigationLink(destination: TestView()) {
                        Image(systemName: "bell")
                    }
                    
                }
                .foregroundColor(Color("textColor"))
                .padding(8)
                .background(Color("secondaryColor"))
                .clipShape(Circle())
                
            }
            .padding(.horizontal)
            
            if showFilter{
                Filters(viewModel: viewModel)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Divider()
        }
        .background(.bar)
    }
    
}



struct CustomNavBar_Previews: PreviewProvider {
    @State static var showFilterPreview = true
    static var previews: some View {
        CustomNavBar(showFilter: $showFilterPreview, viewModel: FilterViewModel(), postViewModel: PostsViewModel(), userViewModel: UserViewModel())
    }
}
