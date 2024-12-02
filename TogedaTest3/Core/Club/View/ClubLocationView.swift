//
//  GroupLocationView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.01.24.
//

import SwiftUI
import MapKit

struct ClubLocationView: View {
    var club: Components.Schemas.ClubDto
    @State var openMapSheet: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text("Location")
                    .font(.body)
                    .fontWeight(.bold)
                
//                Text(locationAddress(club.location))
                Text(club.location.name)
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }
            
            MapSlot(name:  club.title, latitude: club.location.latitude, longitude: club.location.longitude, openGoogleMaps: $openMapSheet)
            
            
        }
        .padding(.horizontal)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .padding(.vertical)
        .background(.bar)
        .cornerRadius(10)
        .confirmationDialog("Select Map", isPresented: $openMapSheet) {
            Button("Open in Apple Maps"){
                let url = URL(string: "maps://?saddr=&daddr=\(club.location.latitude),\(club.location.longitude)")
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
            }
            Button("Open in Google Maps"){
                if isGoogleMapsInstalled() {
                    openGoogleMaps(latitude: club.location.latitude, longitude: club.location.longitude)
                }
            }
        }
    }
}

#Preview {
    ClubLocationView(club: MockClub)
}
