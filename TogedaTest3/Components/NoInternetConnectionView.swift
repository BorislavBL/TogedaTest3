//
//  NoInternetConnectionView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 19.08.24.
//

import SwiftUI

struct NoInternetConnectionView: View {
    var body: some View {
        VStack(spacing: 30){
            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(.gray)
            
            Text("No Internet Connection")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Oops! It looks like you're offline. Please check your internet connection and try again.")
                .font(.body)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, UIScreen.main.bounds.height * 0.2)
            
        }
        .padding(.horizontal)
        .frame(maxHeight: .infinity, alignment: .center)
        .background(.bar)
    }
}

#Preview {
    NoInternetConnectionView()
}
