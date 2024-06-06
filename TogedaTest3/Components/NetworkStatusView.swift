//
//  NetworkStatusView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 29.05.24.
//

import SwiftUI

struct NetworkStatusView: View {
    @Binding var isConnected: Bool
    
    @State private var showStatus = false
    @State private var statusText = "No Internet Connection"
    @State private var statusColor = Color.red
    
    var body: some View {
        VStack {
            if showStatus {
                Text(statusText)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .padding(.horizontal, 30)
                    .background(statusColor)
                    .cornerRadius(50)
                    .padding(.top)
                    .transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .top).combined(with: .opacity)))
                    .animation(.easeInOut(duration: 0.5), value: showStatus)
//                    .edgesIgnoringSafeArea(.top)
            }
        }
        .onChange(of: isConnected) {
            if isConnected {
                statusText = "Connected"
                statusColor = Color.green
                showStatus = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showStatus = false
                    }
                }
            } else {
                statusText = "No Internet Connection"
                statusColor = Color.red
                withAnimation {
                    showStatus = true
                }
            }
        }
    }
}


#Preview {
    NetworkStatusView(isConnected: .constant(true))
}
