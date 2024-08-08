//
//  RefreshableScrollView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 5.06.24.
//

import SwiftUI

struct RefreshableScrollView<Content: View>: View {
    @State private var isCurrentlyRefreshing = false
    var amountToPullBeforeRefreshing: CGFloat = 50
    var topPadding: CGFloat = 0
    
    @State var showRefresh: Bool = false
    @State var canFetch: Bool = true
    
    var onRefresh: () -> Void
    var content: () -> Content
    
    @State var initialValue: CGFloat = 0
    @State var opacityValue: Double = 0
    
    
    var maxValue: CGFloat {
        return initialValue + amountToPullBeforeRefreshing
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            // Custom refresh indicator
            if showRefresh {
                ActivityIndicator(isAnimating: $isCurrentlyRefreshing, style: .large)
//                    .opacity(opacityValue)
                    .padding(.top, topPadding)
                    .padding(.bottom)
            }
            
            
            // Content of the ScrollView
            content()
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .frame(width: 0, height: 0)
                            .onChange(of: geo.frame(in: .global).minY) { oldMinY, newMinY in
                                if newMinY >= maxValue {
                                    isCurrentlyRefreshing = true
 
                                } else if newMinY > initialValue && newMinY < maxValue {
                                    if isCurrentlyRefreshing {
                                        opacityValue = 1
                                    } else {
                                        opacityValue = Double((newMinY - initialValue)/maxValue)
                                    }
                                    withAnimation{
                                        showRefresh = true
                                    }
                                } else if newMinY <= initialValue {
                                    canFetch = true
                                }
                            }
                            .onChange(of: isCurrentlyRefreshing, {
                                if isCurrentlyRefreshing && canFetch {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    onRefresh()
                                    
    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        withAnimation(){
                                            self.showRefresh = false
                                            self.isCurrentlyRefreshing = false
                                        }
                                        
                                        canFetch = false
                                    }
                                }
                            })
                            .onAppear(){
                                initialValue = geo.frame(in: .global).minY
                            }
                    }
                )
        }
    }
}

#Preview {
    RefreshableScrollView(){
        
    } content: {
        LazyVStack{
            ForEach(0..<30, id:\.self){_ in
                Text("hey")
            }
        }
    }
    
}

struct ActivityIndicator: UIViewRepresentable {
    
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: style)
        activityIndicator.hidesWhenStopped = false
        return activityIndicator
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
