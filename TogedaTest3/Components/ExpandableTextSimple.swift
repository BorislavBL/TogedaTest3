//
//  ExpandableTextSimple.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 13.11.24.
//

import SwiftUI

struct ExpandableTextSimple: View {
    @State var isViewed = false
    var text: String
    let lineLimit: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(text)
                .multilineTextAlignment(.leading)
                .lineLimit(isViewed ? nil : lineLimit)
            Button(isViewed ? "Read Less" : "Read More" ) {
                isViewed.toggle()
            }
            .font(.system(size: 15, weight: .semibold))
        }
    }
}

#Preview {
    ExpandableTextSimple(text: "When it comes to chicken there just isn’t anything more delicious than a juicy, crusty piece of finger-licking good fried chicken. It might seem intimidating to fry your own chicken, but it’s actually pretty straightforward and it puts grocery store and fast food fried chicken to shame.  If you have a thermometer for the oil and a timer, you can produce fail-proof fried chicken.  If you’ve ever wanted to make your own fried chicken, now is the time to try!", lineLimit: 6)
}
