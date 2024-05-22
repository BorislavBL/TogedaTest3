//
//  ConfirmLocationMapView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 1.05.24.
//

import SwiftUI
import MapKit

struct ConfirmLocationMapView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var returnedPlace: Place
    /// View Properties
    @State private var camera: MapCameraPosition = .region(.init(center: .applePark, span: .initialSpan))
    @State private var mapSpan: MKCoordinateSpan = .initialSpan
    @State private var coordinate: CLLocationCoordinate2D = .applePark
//    @State private var annotationTitle: String = ""
    @Binding var isActivePrev: Bool
    @Binding var isActive: Bool
    @State var initialPlace: Place?
    
    var body: some View {
        ZStack{
            MapReader { proxy in
                Map(position: $camera) {
                    /// Custom Annotation View
                    Annotation(returnedPlace.name, coordinate: coordinate) {
                        DraggablePin(proxy: proxy, coordinate: $coordinate) { coordinate in
                            findLocationDetails(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), returnedPlace: $returnedPlace){}
                            /// Optional: Updating Camera Position, When Coordinate Changes
                            let newRegion = MKCoordinateRegion(
                                center: coordinate,
                                span: mapSpan
                            )
                            
                            withAnimation(.smooth) {
                                camera = .region(newRegion)
                            }
                        }
                    }
                }
                .onMapCameraChange(frequency: .continuous) { ctx in
                    mapSpan = ctx.region.span
                }
            }
            ConfirmLocationBlock(name: returnedPlace.name, locality: "\(returnedPlace.address)") {
                if let initialPlace = self.initialPlace {
                    returnedPlace = initialPlace
                    setLocation(cameraPosition: $camera, span: 0.05)
                }
            } action: {
                isActive = false
                isActivePrev = false
            }
        }
        .onAppear(){
            setLocation(cameraPosition: $camera, span: 0.05)
            initialPlace = returnedPlace
        }
        .navigationTitle("Select Location")
    }
    
    /// Finds Name for Current Location Coordinates
//    func findCoordinateName() {
//        annotationTitle = ""
//        Task {
//            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//            let geoDecoder = CLGeocoder()
//            if let name = try? await geoDecoder.reverseGeocodeLocation(location).first?.name {
//                annotationTitle = name
//            }
//        }
//    }
//    
    func setLocation(cameraPosition: Binding<MapCameraPosition>, span: CLLocationDegrees) {
        let rpCoordinate = CLLocationCoordinate2D(latitude: returnedPlace.latitude, longitude: returnedPlace.longitude)
        cameraPosition.wrappedValue = .region(MKCoordinateRegion(
            center: rpCoordinate,
            span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
        ))
        coordinate = rpCoordinate
    }
}

/// Custom Draggable Pin Annotation
struct DraggablePin: View {
    var tint: Color = .white
    var proxy: MapProxy
    @Binding var coordinate: CLLocationCoordinate2D
    var onCoordinateChange: (CLLocationCoordinate2D) -> ()
    /// View Properties
    @State private var isActive: Bool = false
    @State private var translation: CGSize = .zero
    var body: some View {
        GeometryReader {
            let frame = $0.frame(in: .global)
            
            Image(systemName: "mappin.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(tint.gradient, .black.gradient)
//                .padding(8)
//                .background{
//                    Circle()
//                        .fill(.black.gradient)
//                }
                .animation(.snappy, body: { content in
                    content
                        /// Scaling on Active
                        .scaleEffect(isActive ? 1.3 : 1, anchor: .bottom)
                })
                .frame(width: frame.width, height: frame.height)
                .onChange(of: isActive, initial: false) { oldValue, newValue in
                    let position = CGPoint(x: frame.midX, y: frame.midY)
                    /// Converting Position into Location Coordinate using Map Proxy
                    if let coordinate = proxy.convert(position, from: .global), !newValue {
                        /// Updating Coordinate based on translation and resetting translation to zero
                        self.coordinate = coordinate
                        translation = .zero
                        onCoordinateChange(coordinate)
                    }
                }
        }
        .frame(width: 30, height: 30)
        .contentShape(.rect)
        .offset(translation)
        .gesture(
            LongPressGesture(minimumDuration: 0.2)
                .onEnded { isActive = $0 }
                .simultaneously(with:
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if isActive { translation = value.translation }
                        }
                        .onEnded { value in
                            if isActive { isActive = false }
                        }
                )
        )
        .sensoryFeedback(.success, trigger: isActive)
    }
}

/// Static Values
extension MKCoordinateSpan {
    static var initialSpan: MKCoordinateSpan {
        return .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
    }
}

extension CLLocationCoordinate2D {
    static var applePark: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 37.334606, longitude: -122.009102)
    }
}

#Preview {
    ConfirmLocationMapView(returnedPlace: .constant(Place(mapItem: MKMapItem())), isActivePrev: .constant(true), isActive: .constant(true))
}
