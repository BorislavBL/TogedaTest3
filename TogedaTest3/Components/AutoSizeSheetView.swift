//
//  AutoSizeSheetView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 11.06.24.
//

import SwiftUI

struct AutoSizeSheetView<Content: View>: View {
    @State private var sheetHeight: CGFloat = .zero
    var alignment: HorizontalAlignment = .leading
    var spacing: CGFloat = 0
    var content: () -> Content
    
    var body: some View {
        VStack(alignment: alignment, spacing: spacing){
            content()
        }
        .padding()
        .overlay {
            GeometryReader { geometry in
                Color.clear.preference(key: InnerHeightPreferenceKey.self, value: geometry.size.height)
            }
        }
        .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
            sheetHeight = newHeight
        }
        .presentationDetents([.height(sheetHeight + 20)])
    }
}

struct InnerHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    AutoSizeSheetView(alignment: .leading, spacing: 20) {
        Text("Hello, World!")
    }
}
