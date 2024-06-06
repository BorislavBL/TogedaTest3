//
//  RefresherViews.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.06.24.
//

import SwiftUI
import Refresher

struct RefresherViews: View {
    var body: some View {
        ScrollView{
            ForEach(0..<20, id: \.self) {index in
                Text("Some text")
            }
        }
        .refresher(refreshView: StandardRefreshView.init) { done in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                done()
            }
        }
    }
}

public struct HomeEmojiRefreshView: View {
    @Binding var state: RefresherState
    @State private var angle: Double = 0.0
    @State private var isAnimating = false
    
    var foreverAnimation: Animation {
        Animation.linear(duration: 1.0)
            .repeatForever(autoreverses: false)
    }
    
    public var body: some View {
        VStack {
            switch state.mode {
            case .notRefreshing:
                Text("🤪")
                    .onAppear {
                        isAnimating = false
                    }
                    .padding(.top, 100)
            case .pulling:
                Text("😯")
                    .rotationEffect(.degrees(360 * state.dragPosition))
                    .padding(.top, 100)
            case .refreshing:
                Text("😂")
                    .rotationEffect(.degrees(self.isAnimating ? 360.0 : 0.0))
                    .onAppear {
                        withAnimation(foreverAnimation) {
                            isAnimating = true
                        }
                    }
                    .padding(.top, 100)

            }
        }
        .scaleEffect(2)
    }
}

public struct StandardRefreshView: View {
    @Binding var state: RefresherState
    @State private var angle: Double = 0.0
    @State private var isAnimating = false
    
    var foreverAnimation: Animation {
        Animation.linear(duration: 1.0)
            .repeatForever(autoreverses: false)
    }
    
    public var body: some View {
        VStack {
            switch state.mode {
            case .notRefreshing:
                ProgressView()
                    .padding(.top, 50)
            case .pulling:
                ProgressView()
                    .padding(.top, 50)
            case .refreshing:
                ProgressView()
                    .padding(.top, 50)

            }
        }
        .scaleEffect(2)
    }
}

#Preview {
    RefresherViews()
}
