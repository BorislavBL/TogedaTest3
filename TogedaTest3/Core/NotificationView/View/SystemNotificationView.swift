//
//  SystemNotificationView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 4.12.23.
//

import SwiftUI

struct SystemNotificationView: View {
    let size: ImageSize = .medium
    var message: String = "Your recent event was banned due to numerous reports."
    var body: some View {
        NavigationLink(destination: TestView()){
            HStack(alignment:.top){
                Image("event_1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.dimension, height: size.dimension)
                    .clipShape(Circle())
                
                Text(message)
                    .font(.footnote)
                    .fontWeight(.semibold) +
                
                Text(" 1 min ago")
                    .foregroundStyle(.gray)
                    .font(.footnote)
            }
            .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    SystemNotificationView()
}
