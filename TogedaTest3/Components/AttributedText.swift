//
//  AttributedText.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 20.11.23.
//


import UIKit
import SwiftUI


struct AttributedText: UIViewRepresentable {
    let text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.dataDetectorTypes = .link
        textView.attributedText = attributedString(for: text)
        textView.backgroundColor = .clear
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedString(for: text)
    }

    private func attributedString(for string: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        let words = string.components(separatedBy: " ")
        var currentIndex = 0

        for word in words {
            let range = NSRange(location: currentIndex, length: word.count)
            if let url = URL(string: word), UIApplication.shared.canOpenURL(url) {
                attributedString.addAttribute(.link, value: url, range: range)
            }
            currentIndex += word.count + 1
        }

        return attributedString
    }
}
