//
//  LoadingButton.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 8.08.25.
//

import SwiftUI

struct LoadingButton<Label: View, LoadingView: View>: View {
    private let action: () async -> Void
    private let label: () -> Label
    private let loadingView: () -> LoadingView
    
    @State private var isLoading = false
    
    /// Creates a LoadingButton.
    /// - Parameters:
    ///   - action: An async closure to perform when the button is tapped.
    ///   - label: A view builder returning the normal button content.
    ///   - loadingView: A view builder returning the loading state content.
    init(
        action: @escaping () async -> Void,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder loadingView: @escaping () -> LoadingView
    ) {
        self.action = action
        self.label = label
        self.loadingView = loadingView
    }
    
    var body: some View {
        Button(action: {
            Task {
                isLoading = true
                defer { isLoading = false }
                await action()
            }
        }) {
            Group {
                if isLoading {
                    loadingView()
                } else {
                    label()
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isLoading)
        }
        .disabled(isLoading)
    }
}

#Preview {
    LoadingButton(action: {}){
        
    } loadingView: {
        
    }
}
