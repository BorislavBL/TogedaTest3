//
//  CategoryView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.09.23.
//

import SwiftUI
import WrappingHStack

struct CategoryView: View {
    @Binding var selectedCategory: String
    @Binding var selectedInterests: [String]
    @Environment(\.dismiss) private var dismiss
    let categories = CategoryOptions.dropLast()
    
    var body: some View {
        ScrollView(){
            
            LazyVStack(alignment: .leading, spacing: 20) {
                Text("Category")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                WrappingHStack(alignment: .leading){
                    ForEach(categories) { category in
                        Button{
                            selectedCategory = category.name
                        } label:{
                            if category.name == selectedCategory{
                                Text(category.name)
                                    .selectedTagTextStyle()
                                    .selectedTagCapsuleStyle()
                            } else {
                                Text(category.name)
                                    .normalTagTextStyle()
                                    .normalTagCapsuleStyle()
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                HStack{
                    Text("Interests")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    Text("\(10 - selectedInterests.count)")
                        .foregroundStyle(.gray)
                        .padding(.horizontal)
                }
                
                WrappingHStack(alignment: .leading){
                    ForEach(InterestOptions, id: \.name) { interest in
                        Button {
                            if selectedInterests.contains(interest.name) {
                                selectedInterests.removeAll { $0 == interest.name }
                            } else {
                                if selectedInterests.count < 10 {
                                    selectedInterests.append(interest.name)
                                }
                            }
                        } label: {
                            if selectedInterests.contains(interest.name) {
                                Text(interest.name)
                                    .selectedTagTextStyle()
                                    .selectedTagCapsuleStyle()
                            } else {
                                Text(interest.name)
                                    .normalTagTextStyle()
                                    .normalTagCapsuleStyle()
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
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

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView(selectedCategory: .constant("Sport"), selectedInterests: .constant([]))
    }
}
