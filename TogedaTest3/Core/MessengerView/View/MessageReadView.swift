//
//  MessageReadView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 21.11.23.
//

import SwiftUI

struct MessageReadView: View {
    @State var date: Date = Date()
    let read: Bool = true
    var sendingCompleted: Bool = true
    var body: some View {
        HStack(alignment: .center, spacing: 5){
            Group{
                if sendingCompleted {
                    Text(separateDateAndTime(from:date).time)
                    if read {
//                        Text("Read")
                        ZStack{
                            Image(systemName: "checkmark")
                                .foregroundStyle(.white)
                            Image(systemName: "checkmark")
                                .offset(CGSize(width: 6.5, height: 0))
                                .foregroundStyle(.white)
                        }
                    } else {
//                        Text("Send")
                        ZStack{
                            Image(systemName: "checkmark")
                                .foregroundStyle(.white.opacity(0.5))
                            Image(systemName: "checkmark")
                                .offset(CGSize(width: 6.5, height: 0))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                } else {
                    Text("Sending...")
                }
            }
            .font(.footnote)
            .foregroundStyle(.gray)
        }
    }
}

#Preview {
    MessageReadView()
}
