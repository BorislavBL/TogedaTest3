//
//  AllowLocationView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 30.10.23.
//

import SwiftUI

struct AllowLocationView: View {
    @State private var showSheet: Bool = false
    
    var body: some View {
        VStack(spacing: 30){
            Image(systemName: "location.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(.gray)
            
            Text("Enable Location Access")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("We require access to your location so we can present you with events and clubs withing your area and allow you to filter based on your proximity.")
                .font(.body)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, UIScreen.main.bounds.height * 0.2)
            
            
            Button{
                showSheet = true
            } label: {
                Text("Allow Location")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("blackAndWhite"))
                    .foregroundColor(Color("testColor"))
                    .fontWeight(.semibold)
                    .cornerRadius(10)
                    .padding(.bottom)
            }
        }
        .padding(.horizontal)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .sheet(isPresented: $showSheet, content: {
            VStack(alignment: .leading, spacing: 16){
                Text("Enable Location Access")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Your location was previously denied. To enable it again: \n\n - Go to Settings \n\n - Tap on Location \n\n - Select While Using the App \n\n - Return to the App")
                    .font(.body)
                    .foregroundStyle(.gray)
                Button{
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                    showSheet = false
                } label: {
                    Text("Go to Settings")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color("blackAndWhite"))
                        .foregroundColor(Color("testColor"))
                        .fontWeight(.semibold)
                        .cornerRadius(10)
                        .padding(.bottom)
                }
            }
            .padding(.all)
            .frame(maxHeight: .infinity, alignment: .top)
            .presentationDetents([.fraction(0.5)])
        })
    }
}

#Preview {
    AllowLocationView()
}
