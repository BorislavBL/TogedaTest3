//
//  SwipeBackModifier.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.07.24.
//

import SwiftUI

struct SwipeBackModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    @GestureState private var dragOffset = CGSize.zero

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .updating($dragOffset) { (value, state, transaction) in
                        if value.translation.width > 100 {
                            dismiss()
                        }
                    }
            )
    }
}

extension View {
    func swipeBack() -> some View {
        self.modifier(SwipeBackModifier())
    }
}

