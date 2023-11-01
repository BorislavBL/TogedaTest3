//
//  CreateEventView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import MapKit

struct TestView: View {
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 20))
                Text("Food Party")
                    .font(.headline)
                Spacer()
            }
            .padding()

            ScrollView {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 10) {
                    ForEach(0..<4) { _ in
                        Image("event_1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 150)
                            .clipped()
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                }
                .padding()
            }

            HStack {
                Spacer()
                Text("+51 >")
                    .foregroundColor(.blue)
                    .padding()
            }
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}


