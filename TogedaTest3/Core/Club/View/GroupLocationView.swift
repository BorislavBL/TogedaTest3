//
//  GroupLocationView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.01.24.
//

import SwiftUI
import MapKit

struct GroupLocationView: View {
    var club: Components.Schemas.ClubDto
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text("Location")
                    .font(.body)
                    .fontWeight(.bold)
                
                Text(locationAddress(club.location))
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }
            
            MapSlot(name:  club.title, latitude: club.location.latitude, longitude: club.location.longitude)
            
            
        }
        .padding(.horizontal)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .padding(.vertical)
        .background(.bar)
        .cornerRadius(10)
    }
}

#Preview {
    GroupLocationView(club: MockClub)
}
