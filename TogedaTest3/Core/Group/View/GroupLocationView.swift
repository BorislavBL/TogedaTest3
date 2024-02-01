//
//  GroupLocationView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.01.24.
//

import SwiftUI
import MapKit

struct GroupLocationView: View {
    @State var address: String?
    @ObservedObject var groupVM: GroupViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text("Location")
                    .font(.body)
                    .fontWeight(.bold)
                
                Text(locationAddress(groupVM.club.baseLocation))
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }
            
            MapSlot(name:  groupVM.club.title, latitude: groupVM.club.baseLocation.latitude, longitude: groupVM.club.baseLocation.longitude)
            
            
        }
        .padding(.horizontal)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .padding(.vertical)
        .background(.bar)
        .cornerRadius(10)
    }
}

#Preview {
    GroupLocationView(groupVM: GroupViewModel())
}
