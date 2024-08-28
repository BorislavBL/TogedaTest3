//
//  ViewGeneral.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 28.08.24.
//

import SwiftUI

extension View{
    /// - For Making it Simple and easy to use
    @ViewBuilder
    func frame(_ size: CGSize)->some View{
        self
            .frame(width: size.width, height: size.height)
    }
    
    /// - Haptic Feedback
    func haptics(_ style: UIImpactFeedbackGenerator.FeedbackStyle){
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
