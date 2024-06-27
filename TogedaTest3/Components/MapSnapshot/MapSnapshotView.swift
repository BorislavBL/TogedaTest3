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
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span))

        let options = MKMapSnapshotter.Options()
        options.region = region
        options.size = CGSize(width: width, height: height)
        options.showsBuildings = true

        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            if let error = error {
                print(error)
                return
            }

            guard let snapshot = snapshot else { return }
            let mapImage = snapshot.image

            let finalImage = UIGraphicsImageRenderer(size: options.size).image { _ in
                mapImage.draw(at: .zero)

                // Create a marker annotation view and configure it
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                let pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)

                // Render the marker annotation view into an image
                let pinImage = UIGraphicsImageRenderer(size: pinView.bounds.size).image { _ in
                    pinView.drawHierarchy(in: pinView.bounds, afterScreenUpdates: true)
                }

                // Calculate the point on the snapshot image to place the marker
                let point = snapshot.point(for: location)
                let pinCenterOffset = CGPoint(x: pinImage.size.width / 2, y: pinImage.size.height / 2)
                let pinPoint = CGPoint(x: point.x - pinCenterOffset.x, y: point.y - pinCenterOffset.y)

                // Draw the marker image at the calculated point
                pinImage.draw(at: pinPoint)
            }
            self.snapshotImage = finalImage
        }
    }

    func snapshotGenerator(width: CGFloat, height: CGFloat) {
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.332077, longitude: -122.02962), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        
        let options = MKMapSnapshotter.Options()
        options.region = region
        
        options.size = CGSize(width: width, height: height)
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start() { snapshot, _ in
            let mapImage = snapshot?.image
            let finalImage = UIGraphicsImageRenderer(size: options.size).image { _ in
                mapImage?.draw(at: .zero)
                let pinView = MKMarkerAnnotationView(annotation: nil, reuseIdentifier: nil)
                let pinImage = pinView.image
                let point = snapshot?.point(for: CLLocationCoordinate2D(latitude: 37.332077, longitude: -122.02962))
                pinImage?.draw(at: point!)
            }
            self.snapshotImage = finalImage
        }
    }
}



let coordinates = CLLocationCoordinate2D(latitude: 37.332077, longitude: -122.02962)

#Preview {
    MapSnapshotView(location: coordinates)
}


