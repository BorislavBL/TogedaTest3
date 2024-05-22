//
//  UserStatsSecond.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.04.24.
//

import SwiftUI

struct UserStatsSecond: View {
    let value: String
    let title: String
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(value)
                .font(.headline)
                .bold()
            Text(title)
                .font(.footnote)
                .bold()
                .foregroundColor(.gray)
        }
        .frame(width: 80, height: 80)
        .background(Color("main-secondary-color").opacity(0.5))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("textColor").opacity(0.5), lineWidth: 1)
        )
    }
}

#Preview {
    UserStatsSecond(value: "500", title: "Friends")
}
