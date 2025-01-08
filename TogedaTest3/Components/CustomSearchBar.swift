//
//  CustomSearchBar.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.10.23.
//

import SwiftUI

struct CustomSearchBar: View {
    
    @Binding var searchText: String
    @Binding var showCancelButton: Bool
    @FocusState private var keyIsFocused: Bool
    var onCommit: () -> Void = {}
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                
                // Search text field
                
                TextField(
                    "Search",
                    text: $searchText,
                    onEditingChanged: { isEditing in
                        if isEditing || !searchText.isEmpty {
                            withAnimation(.linear){
                                self.showCancelButton = true
                            }
                        } else if !isEditing && searchText.isEmpty {
                            withAnimation(.linear){
                                self.showCancelButton = false
                            }
                        }
                    },
                    onCommit: {
                        onCommit()
                    }
                )
                .focused($keyIsFocused)
                .autocorrectionDisabled(true)
                .foregroundColor(.primary)
                .onSubmit {
                    print("down")
                }
                
                // Clear button
                if !searchText.isEmpty {
                    Button(action: {
                        self.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            }
            .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
            .foregroundColor(.secondary) // For magnifying glass and placeholder test
            .background(Color(.tertiarySystemFill))
            .cornerRadius(10.0)
            
            if showCancelButton  {
                // Cancel button
                Button("Cancel") {
                    UIApplication.shared.endEditing(true) // this must be placed before the other commands here
                    self.searchText = ""
                    withAnimation(.linear){
                        self.showCancelButton = false
                    }
                }
                .foregroundColor(Color(.systemBlue))
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .onAppear(){
            self.keyIsFocused = showCancelButton
        }
    }
}

#Preview {
    CustomSearchBar(searchText: .constant(""), showCancelButton: .constant(false))
}

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first?.endEditing(force)
    }
}

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged{_ in
        UIApplication.shared.endEditing(true)
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        modifier(ResignKeyboardOnDragGesture())
    }
}
