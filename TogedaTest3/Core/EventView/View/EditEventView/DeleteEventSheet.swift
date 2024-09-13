//
//  DeleteEventSheet.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 31.08.24.
//

import SwiftUI

struct DeleteEventSheet: View {
    @State var onAction: () -> ()
    var body: some View {
            VStack(spacing: 30){
                Text("All of the information including the chat will be deleted!")
                    .multilineTextAlignment(.leading)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Button{
                    onAction()
                } label:{
                    Text("Delete")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(.red)
                        .cornerRadius(10)
                }
            }
            .padding()
            .presentationDetents([.fraction(0.2)])
        }
}
