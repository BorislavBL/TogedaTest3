//
//  EditAccessibilityView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 11.02.25.
//

import SwiftUI
import Kingfisher

struct EditAccessibilityView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedVisability: Components.Schemas.PostResponseDto.accessibilityPayload
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20){
                VStack(alignment: .leading){
                    Button{
                        selectedVisability = .PUBLIC
                    } label:{
                        HStack {
                            if selectedVisability == .PUBLIC {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .imageScale(.large)
                                    .foregroundStyle(.gray)
                            }
                            Text("Public").tag(Components.Schemas.PostResponseDto.accessibilityPayload.PUBLIC)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "circle")
                            .imageScale(.large)
                            .foregroundStyle(.gray.opacity(0))
                        
                        Text("Everyone will be able see your event.")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }
                
                VStack(alignment: .leading){
                    
                    Button{
                        selectedVisability = .PRIVATE
                    } label:{
                        HStack{
                            if selectedVisability == .PRIVATE{
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .imageScale(.large)
                                    .foregroundStyle(.gray)
                            }
                            Text("Private").tag(Components.Schemas.PostResponseDto.accessibilityPayload.PRIVATE)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "circle")
                            .imageScale(.large)
                            .foregroundStyle(.gray.opacity(0))
                        
                        Text("Your event won't be visible for everyone. In this case you will either have to invite them or attach the event to a club so that only club members could see it.")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }
                
                
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .swipeBack()
            .navigationTitle("Accessibility")
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:Button(action: {dismiss()}) {
                Image(systemName: "chevron.left")
                    .imageScale(.medium)
                    .padding(.all, 8)
                    .background(Color("main-secondary-color"))
                    .clipShape(Circle())
            }
            )
        }.scrollIndicators(.hidden)
        
        
    }
}

#Preview {
    EditAccessibilityView(selectedVisability: .constant(.PUBLIC))
}
