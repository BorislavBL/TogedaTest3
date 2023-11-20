//
//  LPLinkViewRepresented.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.11.23.
//

import LinkPresentation
import SwiftUI

class CustomLinkView: LPLinkView {
    override var intrinsicContentSize: CGSize { CGSize(width: 0, height: super.intrinsicContentSize.height) }
}

struct LPLinkViewRepresented: UIViewRepresentable {
    typealias UIViewType = CustomLinkView
    var metadata: LPLinkMetadata
    
    func makeUIView(context: Context) -> CustomLinkView {
        let linkView = CustomLinkView(metadata: metadata)
        return linkView
    }
    
    func updateUIView(_ uiView: CustomLinkView, context: Context) {}
}
