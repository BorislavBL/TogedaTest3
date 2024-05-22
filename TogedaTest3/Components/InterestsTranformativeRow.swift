//
//  InterestsTranformativeRow.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 29.04.24.
//

import SwiftUI

struct InterestsTranformativeRow: View {
    var interests: [Interest]
    var body: some View {
        ScrollView(.horizontal){
            VStack(alignment: .leading){
                HStack(){
                    ForEach(interests[..<firstIndex()], id: \.self){interest in
                        Text("\(interest.icon) \(interest.name)")
                            .normalTagTextStyle()
                            .normalTagCapsuleStyle()
                    }
                }
                HStack{
                    ForEach(interests[firstIndex()..<secondIndex()], id: \.self){interest in
                        Text("\(interest.icon) \(interest.name)")
                            .normalTagTextStyle()
                            .normalTagCapsuleStyle()
                    }
                }
                HStack{
                    ForEach(interests[secondIndex()..<thirdIndex()], id: \.self){interest in
                        Text("\(interest.icon) \(interest.name)")
                            .normalTagTextStyle()
                            .normalTagCapsuleStyle()
                    }
                }
                HStack{
                    ForEach(interests[thirdIndex()..<forthIndex()], id: \.self){interest in
                        Text("\(interest.icon) \(interest.name)")
                            .normalTagTextStyle()
                            .normalTagCapsuleStyle()
                    }
                }
                HStack{
                    ForEach(interests[forthIndex()...], id: \.self){interest in
                        Text("\(interest.icon) \(interest.name)")
                            .normalTagTextStyle()
                            .normalTagCapsuleStyle()
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
    
    func firstIndex() -> Int {
        return interests.count / 5
    }
    
    func secondIndex() -> Int {
        return 2 * interests.count / 5
    }
    
    func thirdIndex() -> Int {
        return 3 * interests.count / 5
    }
    
    func forthIndex() -> Int {
        return 4 * interests.count / 5
    }
}

#Preview {
    InterestsTranformativeRow(interests: Interest.HobbyInterests)
}
