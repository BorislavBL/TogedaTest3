//
//  SnapShotView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 16.09.24.
//

import SwiftUI

struct SnapshotView<Content: View>: UIViewRepresentable {
    let content: Content
    let completion: (UIImage?) -> Void
    
    init(@ViewBuilder content: () -> Content, completion: @escaping (UIImage?) -> Void) {
        self.content = content()
        self.completion = completion
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            self.takeSnapshot(of: uiView)
        }
    }
    
    private func takeSnapshot(of view: UIView) {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        let image = renderer.image { context in
            view.layer.render(in: context.cgContext)
        }
        completion(image)
 
    }
 }
