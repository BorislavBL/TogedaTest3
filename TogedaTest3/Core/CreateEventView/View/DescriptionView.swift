//
//  DescriptionView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 17.09.23.
//

import SwiftUI

struct DescriptionView: View {
    @State private var bio = ""
    @Environment(\.dismiss) private var dismiss
    
    let placeholder = "Describe the purpose of your event. What activities are you planning? Mention any special guests who might be attending. Will there be food and drinks? Help attendees know what to expect."
    
    var body: some View {
        VStack(alignment:.leading){
            
            HStack{
                Spacer()
                Button(action:{dismiss()}) {
                    Image(systemName: "xmark")
                        .padding(.all, 8)
                        .background(Color("secondaryColor"))
                        .clipShape(Circle())
                }
            }
            .padding()
            
            ScrollView{
                LazyVStack(alignment: .leading) {
                    
                    
                    Text("Description")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    TextField(placeholder, text: $bio, axis: .vertical)
                        .lineLimit(20, reservesSpace: true)
                        .padding(.horizontal)
                }
            }
        }
    }
}

struct DescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        DescriptionView()
    }
}
