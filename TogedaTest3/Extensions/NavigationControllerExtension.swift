//
//  NavigationControllerExtension.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 2.11.23.
//

import UIKit
import SwiftUI

//extension UINavigationController: UIGestureRecognizerDelegate {
//    open override func viewDidLoad() {
//        super.viewDidLoad()
//        interactivePopGestureRecognizer?.delegate = self
//    }
//    
//    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return viewControllers.count > 1
//    }
//}

//struct SwipeBackGesture: UIViewControllerRepresentable {
//    var onSwipe: () -> Void
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    func makeUIViewController(context: Context) -> some UIViewController {
//        let viewController = UIViewController()
//        let gestureRecognizer = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan))
//        viewController.view.addGestureRecognizer(gestureRecognizer)
//        
//        return viewController
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//        
//    }
//    
//    class Coordinator: NSObject {
//        var swipeBackGesture: SwipeBackGesture
//        
//        init(_ swipeBackGesture: SwipeBackGesture) {
//            self.swipeBackGesture = swipeBackGesture
//        }
//        
//        @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
//            let translation = gestureRecognizer.translation(in: nil)
//            let progress = translation.x / 200
//            if gestureRecognizer.state == .ended {
//                if progress > 0.5 {
//                    swipeBackGesture.onSwipe()
//                }
//            }
//            
//            
//        }
//    }
//    
//}

//https://stackoverflow.com/questions/59921239/hide-navigation-bar-without-losing-swipe-back-gesture-in-swiftui

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 18.0, *) {
            interactivePopGestureRecognizer?.delegate = self
        }
    }
    
    // Allows swipe back gesture after hiding standard navigation bar with .navigationBarHidden(true).
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if #available(iOS 18.0, *) {
            if topViewController?.presentedViewController != nil {
                return false // A sheet is currently presented
            }
            return viewControllers.count > 1
        }
        
        return true // Default behavior for iOS 17 and below
    }
    
    // Allows interactivePopGestureRecognizer to work simultaneously with other gestures.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if #available(iOS 18.0, *) {
            return viewControllers.count > 1
        }
        
        return false // Default behavior for iOS 17 and below
    }
    
    // Blocks other gestures when interactivePopGestureRecognizer begins.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if #available(iOS 18.0, *) {
            return viewControllers.count > 1
        }
        
        return false // Default behavior for iOS 17 and below
    }
}

