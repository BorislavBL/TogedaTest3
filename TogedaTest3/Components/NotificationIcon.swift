//
//  NotificationIcon.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 1.04.25.
//

import SwiftUI

struct NotificationIcon: View {
    var systemImageName: String
    var showDot: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: systemImageName)
                .font(.system(size: 30))
                .padding()

            if showDot {
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                    .offset(x: 5, y: -5)
            }
        }
    }
}

#Preview {
    NotificationIcon(systemImageName: "bell", showDot: true)
}
