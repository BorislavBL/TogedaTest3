//
//  LocationRequestIsOnView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 1.10.24.
//


//import ClusterMapSwiftUI
import ClusterMap
import ClusterMapSwiftUI
import MapKit
import SwiftUI

@available(iOS 17.0, *)
struct ModernMap: View {
    @StateObject var dataSource = DataSource()

    var body: some View {
        Map(
            initialPosition: .region(dataSource.currentRegion),
            interactionModes: .all
        ) {
            ForEach(dataSource.annotations) { item in
                Marker(
                    "\(item.coordinate.latitude) \(item.coordinate.longitude)",
                    systemImage: "mappin",
                    coordinate: item.coordinate
                )
                .annotationTitles(.hidden)
            }
            ForEach(dataSource.clusters) { item in
                Marker(
                    "\(item.count)",
                    systemImage: "square.3.layers.3d",
                    coordinate: item.coordinate
                )
            }
        }
        .readSize(onChange: { newValue in
            dataSource.mapSize = newValue
        })
        .onMapCameraChange { context in
            dataSource.currentRegion = context.region
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            Task.detached {
                await dataSource.reloadAnnotations()
            }
        }
        .overlay(alignment: .bottom, content: {
            HStack {
                Button("Add annotations") {
                    Task{
//                        await dataSource.addAnnotations()
                    }
                }
                Spacer()
                Button("Remove annotations") {
                    Task{
                        await dataSource.removeAnnotations()
                    }
                }
            }
            .padding()
        })
    }
}

#Preview {
    ModernMap()
}

