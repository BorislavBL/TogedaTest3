//
//  KeyboardResponser.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 28.08.24.
//

import SwiftUI
import Combine

//final class KeyboardResponder: ObservableObject {
//    @Published var currentHeight: CGFloat = 0
//
//    var keyboardWillShowNotification = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
//    var keyboardWillHideNotification = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
//
//    init() {
//        keyboardWillShowNotification.map { notification in
//            CGFloat((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0)
//        }
//        .assign(to: \.currentHeight, on: self)
//        .store(in: &cancellableSet)
//
//        keyboardWillHideNotification.map { _ in
//            CGFloat(0)
//        }
//        .assign(to: \.currentHeight, on: self)
//        .store(in: &cancellableSet)
//    }
//
//    private var cancellableSet: Set<AnyCancellable> = []
//}


struct KeyboardProvider: ViewModifier {
    
    var keyboardHeight: Binding<CGFloat>
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification),
                       perform: { notification in
                guard let userInfo = notification.userInfo,
                      let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                                                            
                self.keyboardHeight.wrappedValue = keyboardRect.height
                
            }).onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification),
                         perform: { _ in
                self.keyboardHeight.wrappedValue = 0
            })
    }
}


public extension View {
    func keyboardHeight(_ state: Binding<CGFloat>) -> some View {
        self.modifier(KeyboardProvider(keyboardHeight: state))
    }
}
