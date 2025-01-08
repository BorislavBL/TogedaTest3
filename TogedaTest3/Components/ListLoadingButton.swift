//
//  LoadingButtonForLists.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 7.01.25.
//

import SwiftUI

struct ListLoadingButton: View {
    @Binding var isLoading: Bool
    var isLastPage: Bool
    var asyncFunction: () -> ()
    
    var body: some View {
        if !isLastPage{
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Button{
                    isLoading = true
                    asyncFunction()
                } label: {
                    Text("Load More")
                        .selectedTagTextStyle()
                        .selectedTagRectangleStyle()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

#Preview {
    ListLoadingButton(isLoading: .constant(false), isLastPage: false, asyncFunction: {})
}
