//
//  DescriptionView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 17.09.23.
//

import SwiftUI

struct DescriptionView: View {
    @Binding var description: String
    @Environment(\.dismiss) private var dismiss
    @State private var showWarning = false
    
    var placeholder: String
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment: .leading) {
//                
//                
//                Text("Description")
//                    .font(.title3)
//                    .fontWeight(.bold)
//                    .padding(.horizontal)
//                
//                if showWarning {
//                    HStack(spacing: 5){
//                        Image(systemName: "exclamationmark.circle")
//                            .foregroundStyle(.red)
//                        Text("Description should not contain any links.")
//                            .foregroundStyle(.red)
//                    }
//                    .padding(.vertical, 8)
//                    .padding(.horizontal)
//                }
                
                TextField(placeholder, text: $description, axis: .vertical)
                    .lineLimit(20, reservesSpace: true)
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .swipeBack()
        .navigationTitle("Description")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {
//            if !containsLink(text: description){
                dismiss()
//            } else {
//                showWarning = true
//            }
        }) {
            Image(systemName: "chevron.left")
                .imageScale(.medium)
                .padding(.all, 8)
                .background(Color("main-secondary-color"))
                .clipShape(Circle())
        }
        )
        
    }

}

struct DescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        DescriptionView(description: .constant(""), placeholder: "Describe the purpose of your event. What activities are you planning? Mention any special guests who might be attending. Will there be food and drinks? Help attendees know what to expect.")
    }
}
