//
//  HiddenPageView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.11.24.
//

import SwiftUI

struct HiddenPageView: View {
    @Environment(\.dismiss) var dismiss
    var undoAction: () -> ()
    var body: some View {
        ZStack(alignment: .top){
            VStack(spacing: 16){
                Text("🫥")
                    .font(.custom(NSUUID().uuidString, size: 120))
                Text("Hidden Event!")
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("This event won’t appear to you in the feed again. Changed your mind? Tap the undo button below.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                
                Button{
                    undoAction()
                } label: {
                    Text("Undo")
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
                
                Button{
                    dismiss()
                } label: {
                    Text("Go Back")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding()
            
            HStack{
                Button(action: {dismiss()}) {
                    Image(systemName: "chevron.left")
                        .frame(width: 35, height: 35)
                        .background(.bar)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                }
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.bar)
        .swipeBack()
    }
}
#Preview {
    HiddenPageView(undoAction: {})
}
