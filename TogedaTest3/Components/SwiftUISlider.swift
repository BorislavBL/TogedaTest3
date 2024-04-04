//
//  SwiftUISlider.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 5.03.24.
//

import SwiftUI

struct SwiftUISlider: UIViewRepresentable {
    final class Coordinator: NSObject {
        // The class property value is a binding: It’s a reference to the SwiftUISlider
        // value, which receives a reference to a @State variable value in ContentView.
        var value: Binding<Int>
        
        // Create the binding when you initialize the Coordinator
        init(value: Binding<Int>) {
            self.value = value
        }
        
        // Create a valueChanged(_:) action
        @objc func valueChanged(_ sender: UISlider) {
            self.value.wrappedValue = Int(sender.value)
        }
    }
    
    var thumbColor: UIColor = .white
    var minTrackColor: UIColor?
    var maxTrackColor: UIColor?
    
    @Binding var value: Int
    
    func makeUIView(context: Context) -> UISlider {
        let slider = UISlider(frame: .zero)
        slider.thumbTintColor = thumbColor
        slider.minimumTrackTintColor = minTrackColor
        if let color = maxTrackColor {
            slider.maximumTrackTintColor = color
        }
        slider.value = Float(value)
        slider.maximumValue = Float(300)
        slider.minimumValue = Float(1)
        
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )
        
        return slider
    }
    
    func updateUIView(_ uiView: UISlider, context: Context) {
        // Coordinating data between UIView and SwiftUI view
        uiView.value = Float(self.value)
    }
    
    func makeCoordinator() -> SwiftUISlider.Coordinator {
        Coordinator(value: $value)
    }
}
