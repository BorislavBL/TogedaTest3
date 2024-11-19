//
//  ShareSheet.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 24.01.24.
//

import SwiftUI

struct ActiveShareSheet: UIViewControllerRepresentable {
    var item: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No need to update the view controller in this use case.
    }
}

struct ShareSheet: View {
    var link: URL
    
    @State private var sheetHeight: CGFloat = .zero
    
    var body: some View {
        VStack{
            ActiveShareSheet(item: link)
        }
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
