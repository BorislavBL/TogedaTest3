//
//  InterestsMoreLess.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 29.04.24.
//

import SwiftUI
import WrappingHStack

struct InterestsMoreLess: View {
    @State var isMore = false
    var interests: [Interest] = Interest.HobbyInterests
    @State var amount = 10
    var body: some View {
        WrappingHStack(alignment: .leading){
             if interests.count >= amount {
                ForEach(interests[..<amount], id: \.self){interest in
                    Text("\(interest.icon) \(interest.name)")
                        .normalTagTextStyle()
                        .normalTagCapsuleStyle()
                }
                
                Button{
                    isMore.toggle()
                    if isMore {
                        amount = interests.count
                    } else {
                        amount = 10
                    }
                } label:{
                    if isMore {
                        Text("Less")
                            .selectedTagTextStyle()
                            .selectedTagCapsuleStyle()
                    } else {
                        Text("More")
                            .normalTagTextStyle()
                            .normalTagCapsuleStyle()
                    }
                }
            } else {
                ForEach(interests, id: \.self){interest in
                    Text("\(interest.icon) \(interest.name)")
                        .normalTagTextStyle()
                        .normalTagCapsuleStyle()
                }
                
            }
        }
    }
}

#Preview {
    InterestsMoreLess()
}
