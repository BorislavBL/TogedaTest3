//
//  CreateSheetView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 9.01.24.
//

import SwiftUI

struct CreateSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var sheetHeight: CGFloat = .zero
    @Binding var showSheet: Bool
    @Binding var showCreateEvent: Bool
    @Binding var showCreateClub: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20){
            HStack{
                Spacer()
                Button{dismiss()} label:{
                    Image(systemName: "xmark")
                        .frame(width: 35, height: 35)
                        .background(Color("secondaryColor"))
                        .clipShape(Circle())
                }
            }
            
            Button{
                showSheet = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showCreateClub = true
                }
                
            } label:{
                HStack{
                    Image(systemName: "plus")
                        .frame(width: 35, height: 35)
                        .background(Color("secondaryColor"))
                        .clipShape(Circle())
                    Text("Create a Club")
                        .fontWeight(.semibold)
                }
            }
            
            Button{
                showSheet = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showCreateEvent = true
                }
            } label:{
                HStack{
                    Image(systemName: "plus")
                        .frame(width: 35, height: 35)
                        .background(Color("secondaryColor"))
                        .clipShape(Circle())
                    Text("Create an Event")
                        .fontWeight(.semibold)
                }
            }
            
        }
        .padding()
        .overlay {
            GeometryReader { geometry in
                Color.clear.preference(key: InnerHeightPreferenceKey.self, value: geometry.size.height)
            }
        }
        .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
            sheetHeight = newHeight
        }
        .presentationDetents([.height(sheetHeight + 20)])
    }
}

#Preview {
    CreateSheetView(showSheet: .constant(false), showCreateEvent: .constant(false), showCreateClub: .constant(false))
}
