//
//  UpdateAppView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.10.24.
//

import SwiftUI

struct UpdateAppView: View {
    var body: some View {
        VStack(spacing: 30){
            Text("😁")
                .font(.custom("", size: 120))
            
            Text("Time To Update!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("We’ve been busy adding awesome new features and squashing those pesky bugs to make your experience smoother than ever. Update now and enjoy the ride!")
                .font(.body)
                .foregroundStyle(.gray)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.bottom, UIScreen.main.bounds.height * 0.2)
            
            Button{
                if let url = URL(string: TogedaLinks().appstore) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } label:{
                Text("Update App")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .fontWeight(.semibold)
                    .cornerRadius(10)
            }
            
        }
        .padding(.horizontal)
        .frame(maxHeight: .infinity, alignment: .center)
        .background(.bar)
    }
}

#Preview {
    UpdateAppView()
}
