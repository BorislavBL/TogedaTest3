//
//  ProfileTabs.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

struct ProfileTabs: View {
    let tabs: [String] = ["About", "Events", "Clubs", "Badges", "Calendar"]
    
    @Binding var tabIndex: Int
    @Binding var offset: CGFloat
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            
            ForEach(0..<tabs.count, id:\.self) {index in
                Button {
                    Task {
                        withAnimation {
                            tabIndex = index
                            offset = UIScreen.main.bounds.width * (2 - CGFloat(index))
                        }
                    }
                } label: {
                    if tabIndex == index {
                        Text(tabs[index])
                            .selectedTagTextStyle()
                            .selectedTagCapsuleStyle()
                    } else {
                        Text(tabs[index])
                            .normalTagTextStyle()
                            .normalTagCapsuleStyle()
                    }
                }
            }
            
            
        }
    }
}

struct ProfileTabs_Previews: PreviewProvider {
    @State static var tabIndex: Int = 0
    @State static var offset: CGFloat = 2 * UIScreen.main.bounds.width
    static var previews: some View {
        ProfileTabs(tabIndex: $tabIndex, offset: $offset)
    }
}
