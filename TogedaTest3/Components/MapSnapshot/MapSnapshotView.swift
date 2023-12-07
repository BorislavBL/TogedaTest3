//
//  MapSnapshotView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 4.12.23.
//

import SwiftUI
import MapKit

struct MapSnapshotView: View {
  let location: CLLocationCoordinate2D
  var span: CLLocationDegrees = 0.01

  @State private var snapshotImage: UIImage? = nil

  var body: some View {
      Group {
        if let image = snapshotImage {
          Image(uiImage: image)
        } else {
          ProgressView()
          .progressViewStyle(CircularProgressViewStyle())
          .background(Color(UIColor.secondarySystemBackground))
        }
      }
      .onAppear {
        generateSnapshot(width: 1300, height: 400)
      }
  }
    func generateSnapshot(width: CGFloat, height: CGFloat) {

      // The region the map should display.
//      let region = MKCoordinateRegion(
//        center: self.location,
//        span: MKCoordinateSpan(
//          latitudeDelta: self.span,
//          longitudeDelta: self.span
//        )
//      )
//        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.332077, longitude: -122.02962), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))

      // Map options.
      let mapOptions = MKMapSnapshotter.Options()
      mapOptions.region = region
      mapOptions.size = CGSize(width: width, height: height)
        mapOptions.showsBuildings = true

      // Create the snapshotter and run it.
      let snapshotter = MKMapSnapshotter(options: mapOptions)
      snapshotter.start { (snapshotOrNil, errorOrNil) in
        if let error = errorOrNil {
          print(error)
          return
        }
        if let snapshot = snapshotOrNil {
          self.snapshotImage = snapshot.image
        }
      }
    }
}

let coordinates = CLLocationCoordinate2D(latitude: 37.332077, longitude: -122.02962)
#Preview {
    MapSnapshotView(location: coordinates)
}


