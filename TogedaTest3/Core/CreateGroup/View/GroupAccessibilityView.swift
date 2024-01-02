//
//  GroupAccessibilityView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 29.12.23.
//

import SwiftUI

struct GroupAccessibilityView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedVisability: Visabilities
    
    var body: some View {
        List {
            Text("Accessibility")
                .font(.title3)
                .fontWeight(.bold)
                .listRowSeparator(.hidden)

            
            Picker("", selection: $selectedVisability) {
                Text("Public").tag(Visabilities.Public)
                Text("Private").tag(Visabilities.Private)
                Text("Ask To Join").tag(Visabilities.Ask_to_join)
            }
            .labelsHidden()
            .pickerStyle(InlinePickerStyle())
            
            Group{
                if selectedVisability == .Public {
                    Text("Everyone will be able to join your group without any restrictions.")
                    
                } else if selectedVisability == .Private {
                    Text("Your group won't be visable on the feed page and people will be able to join it only if you personally invite them.")
                } else if selectedVisability == .Ask_to_join {
                    Text("Your group will be visable to everyone but people will have to request access in order to join.")
                }
            }
            .font(.callout)
            .foregroundColor(.gray)
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
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

#Preview {
    GroupAccessibilityView(selectedVisability: .constant(.Public))
}
