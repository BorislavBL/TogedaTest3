//
//  AttributedText.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 20.11.23.
//


import UIKit
import SwiftUI

func textWithLinks(text: String) -> Text{
    var output = Text("")
    let words = text.components(separatedBy: " ")
    
    for word in words {
        if let url = URL(string: word), UIApplication.shared.canOpenURL(url) {
            output = output + Text(" ") + Text(.init(word)).underline()
        } else {
            output = output + Text(" ") + Text(word)
        }
    }
    
    return output
}

