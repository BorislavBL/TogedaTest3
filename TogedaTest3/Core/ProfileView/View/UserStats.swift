//
//  UserStats.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct UserStats: View {
    let value: String
    let title: String
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(value)
                .font(.title3)
                .bold()
            Text(title)
                .font(.footnote)
                .bold()
                .foregroundColor(.gray)
        }
    }
}

struct UserStats_Previews: PreviewProvider {
    static var previews: some View {
        UserStats(value: "500", title: "Friends")
    }
}

