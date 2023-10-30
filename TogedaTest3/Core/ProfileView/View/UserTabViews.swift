//
//  UserTabViews.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 25.10.23.
//

import SwiftUI

struct UserTabViews: View {
    
    let title: String
    let filters: [String]
    
    @State var selectedFilter: String = "All"
    @Environment(\.dismiss) private var dismiss
    private let gridItems: [GridItem] = [
        .init(.flexible(), spacing: 2),
        .init(.flexible(), spacing: 2),
        .init(.flexible(), spacing: 2),
    ]
    
    var body: some View {
        
        ScrollView{
            VStack (alignment: .leading, spacing: 20) {
                Text(title)
                    .font(.body)
                    .fontWeight(.bold)
                
                HStack(alignment: .center, spacing: 5) {
                    
                    ForEach(filters, id:\.self) {filter in
                        Button {
                            selectedFilter = filter
                        } label: {
                            if selectedFilter == filter {
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
                
                
                LazyVGrid(columns: gridItems, spacing: 10) {
                    ForEach(0..<20, id: \.self){ abouts in
                        EventComponent()
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            .padding()

            
        }
        .background(.bar)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .imageScale(.medium)
                .padding(.all, 8)
                .background(Color("secondaryColor"))
                .clipShape(Circle())
        }
        )
        
    }
}

#Preview {
    UserTabViews(title: "Events", filters: ["All", "Current", "Past"])
}
