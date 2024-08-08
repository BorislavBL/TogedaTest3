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

