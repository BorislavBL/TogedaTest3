//
//  BottomBarModifier.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 30.07.24.
//

import SwiftUI

extension View {
    func bottomBar<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        modifier(Modifier(barContent: content))
    }
}

struct Modifier<BarContent : View>: ViewModifier {
    
    @ViewBuilder
    let barContent: BarContent
    
    @State
    private var height: CGFloat?
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
                .safeAreaPadding(.bottom, height)
                .ignoresSafeArea(.all, edges: .bottom) // this is for SwiftUI layout interactive dissmissing animation bug
            
            UIBottomBar.ViewRepresentable {
                barContent
            } background: {
                Color.clear.background(Material.bar).readSize { height = $0.height }
            }.border(.blue)
        }
    }
}

struct ReadSizeModifier: ViewModifier {
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content.background(GeometryReader { geometry in
            Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
        })
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            DispatchQueue.main.async {
                self.size = preferences
            }
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        self.modifier(ReadSizeModifier(size: .constant(.zero)))
            .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}
