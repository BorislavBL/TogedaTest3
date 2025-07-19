//
//  PageNotFoundView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 14.08.24.
//

import SwiftUI

struct PageNotFoundView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack(alignment: .top){
            VStack(spacing: 16){
                Text("🤯")
                    .font(.custom(NSUUID().uuidString, size: 120))
                Text("Opss, Page Not Found.")
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("The page you are looking for was probably deleted.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                
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
    PageNotFoundView()
}
