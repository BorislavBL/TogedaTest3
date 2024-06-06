//
//  RefreshableScrollView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 5.06.24.
//

import SwiftUI

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct RefreshableScrollView<Content: View>: View {
    @Environment(\.refresh) private var refresh
    @State private var isCurrentlyRefreshing = false
    let amountToPullBeforeRefreshing: CGFloat = 180
    
    var onRefresh: () -> Void
    var content: () -> Content
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                // Custom refresh indicator
                if isCurrentlyRefreshing {
                    ProgressView("Refreshing...").padding()
                }
                
                // Content of the ScrollView
                content()
            }
            .overlay(GeometryReader { geo in
                let currentScrollViewPosition = -geo.frame(in: .global).origin.y
                
                if currentScrollViewPosition < -amountToPullBeforeRefreshing && !isCurrentlyRefreshing {
                    Color.clear.preference(key: ViewOffsetKey.self, value: -geo.frame(in: .global).origin.y)
                }
            })
        }
        .onPreferenceChange(ViewOffsetKey.self) { scrollPosition in
            if scrollPosition < -amountToPullBeforeRefreshing && !isCurrentlyRefreshing {
                isCurrentlyRefreshing = true
                Task {
                    onRefresh()
                    await MainActor.run {
                        isCurrentlyRefreshing = false
                    }
                }
            }
        }
    }
}

#Preview {
    RefreshableScrollView() {
        
    } content: {
        VStack{
            Text("hey")
        }
    }

}
