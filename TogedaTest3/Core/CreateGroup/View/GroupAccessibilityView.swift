//
//  GroupAccessibilityView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 29.12.23.
//

import SwiftUI

struct GroupAccessibilityView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedVisability: String
    @Binding var askToJoin: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20){
            VStack(alignment: .leading){
                Button{
                    selectedVisability = "PUBLIC"
                } label:{
                    HStack {
                        if selectedVisability == "PUBLIC" {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .foregroundStyle(.blue)
                        } else {
                            Image(systemName: "circle")
                                .imageScale(.large)
                                .foregroundStyle(.gray)
                        }
                        Text("Public").tag("PUBLIC")
                    }
                }
                
                HStack {
                        Image(systemName: "circle")
                            .imageScale(.large)
                            .foregroundStyle(.gray.opacity(0))
                    
                    Text("Everyone will be able to join your group without any restrictions.")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading){
                
                Button{
                    selectedVisability = "PRIVATE"
                } label:{
                    HStack{
                        if selectedVisability == "PRIVATE"{
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .foregroundStyle(.blue)
                        } else {
                            Image(systemName: "circle")
                                .imageScale(.large)
                                .foregroundStyle(.gray)
                        }
                        Text("Private").tag("PRIVATE")
                    }
                }
                
                HStack {
                        Image(systemName: "circle")
                            .imageScale(.large)
                            .foregroundStyle(.gray.opacity(0))
                    
                    Text("Your group won't be visible on the feed page and people will be able to join it only if you personally invite them.")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
            }

            VStack(alignment: .leading){
                Toggle(isOn: $askToJoin) {
                    Text("Ask for permission")
                        .fontWeight(.semibold)
                }
                
                Text("Each user will have to be approved by you in order to join.")
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .swipeBack()
        .navigationTitle("Accessibility")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .imageScale(.medium)
                .padding(.all, 8)
                .background(Color("main-secondary-color"))
                .clipShape(Circle())
        }
        )
        
        
    }
}

#Preview {
    GroupAccessibilityView(selectedVisability: .constant("PUBLIC"), askToJoin: .constant(true))
}


