//
//  MapView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 19.09.23.
//

import SwiftUI
import MapKit

struct MapView: View {
    //    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 41.89, longitude: 12.49), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    //    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    @StateObject var viewModel = MapViewModel()
    @EnvironmentObject var locationManager: LocationManager

    @Namespace private var locationSpace

    @State var showSearch: Bool = false
    
    @State private var address: String?
    
    @StateObject var filterViewModel = FilterViewModel()
    
    @State private var isInitialLocationSet = false
    
    @State private var offset = CGSize.zero
    var body: some View {
        //        UIMap()
        //            .edgesIgnoringSafeArea(.top)
        
        ZStack(alignment: .top){
            Map(position: $viewModel.cameraPosition, interactionModes: [.zoom, .pan], selection: $viewModel.mapSelection, scope: locationSpace) {
                
                ForEach(viewModel.mapPosts, id: \.id) { post in
                    
                    Marker(post.title, coordinate: CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude))
                        .tag(post)
                        .tint(.black)
                    
                }
                
                UserAnnotation()
            }
//            .environment(\.colorScheme, .light)
            .onMapCameraChange { context in
                viewModel.visibleRegion = context.region
            }
            .onAppear(){
                if !isInitialLocationSet {
                    setLocation(cameraPosition: $viewModel.cameraPosition, span: 0.1)
                    isInitialLocationSet = true
                }
            }
            .overlay(alignment: .bottomTrailing) {
                VStack(spacing: 15){
                    MapCompass(scope: locationSpace)
                    //                    MapPitchToggle(scope: locationSpace)
                    Button {
                        if let region = viewModel.visibleRegion {
                            viewModel.mapPosts = Post.MOCK_POSTS.filter{
                                isLocationInsideVisibleRegion(latitude: $0.location.latitude, longitude: $0.location.longitude, region: region)
                            }
                            print(region)
                        }
                    } label: {
                        Image(systemName: "location.viewfinder")
                            .padding(12)
                            .background(.ultraThickMaterial)
                            .clipShape(Circle())
                    }
                    MapUserLocationButton(scope: locationSpace)
                }
                .buttonBorderShape(.circle)
                .padding()
            }
            .tint(.blue)
            .overlay{
                if showSearch {
                    ScrollView{
                        LazyVStack(alignment: .leading, spacing: 10){
                            ForEach(viewModel.searchResults, id:\.id){ post in
                                Button {
                                    viewModel.searchText = ""
                                    UIApplication.shared.endEditing(true)
                                    withAnimation(.snappy){
                                        viewModel.cameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude), latitudinalMeters: 5000, longitudinalMeters: 5000))
                                        viewModel.mapSelection = post
                                    }
                                    showSearch = false
                                } label: {
                                    Text(post.title)
                                        .padding(.vertical, 3)
                                        .padding(.horizontal)
                                }
                                Divider()
                            }
                            
                        }
                        
                    }
                    .padding(.top, 60)
                    .padding(.vertical)
                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
                    .background()
                }
            }
            .ignoresSafeArea(.keyboard)
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .mapControls{}
            .mapScope(locationSpace)
            //            .navigationTitle("Map")
            //            .navigationBarTitleDisplayMode(.inline)
            //            .searchable(text: $searchText, isPresented: $showSearch, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: viewModel.searchText){
                if !viewModel.searchText.isEmpty {
                    viewModel.mapSelection = nil
                    viewModel.searchResults = viewModel.mapPosts.filter{ result in
                        result.title.lowercased().contains(viewModel.searchText.lowercased())
                    }
                } else {
                    viewModel.searchResults = viewModel.mapPosts
                }
            }
            .onChange(of: viewModel.mapSelection, { oldValue, newValue in
                if let post = newValue {
                    reverseGeocode(coordinate: CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude)) { result in
                        address = result
                    }
                    
                    withAnimation(.linear) {
                        viewModel.selectedPost = post
                        viewModel.showPostView = true
                        
                    }
                    
                } else {
                    withAnimation(.linear) {
                        viewModel.showPostView = false
                    }
                    
                }
            })
            .onSubmit(of: .search) {
                Task {
                    guard !viewModel.searchText.isEmpty else {return}
                    print("submit")
                }
            }
            
            
            MapNavBar(searchText: $viewModel.searchText, showSearch: $showSearch, viewModel: filterViewModel)

        }
        .sheet(isPresented: $filterViewModel.showAllFilter){
            AllInOneFilterView()
                .presentationDetents([.fraction(0.99)])
                .presentationDragIndicator(.visible)
        }
        .overlay(alignment:.bottom) {
            if viewModel.showPostView && !showSearch {
                NavigationLink(value: SelectionPath.eventDetails(viewModel.selectedPost)){
                    EventMapPreview(post: viewModel.selectedPost, address: address)
                }
                .frame(height: 170)
                .frame(maxWidth: UIScreen.main.bounds.width, alignment: .leading)
                .background(.bar)
                .cornerRadius(20)
                .padding(8)
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                .offset(x:0, y: offset.height)
                .highPriorityGesture(
                    DragGesture()
                        .onChanged {gesture in
                            offset = gesture.translation
                        }
                        .onEnded({ _ in
                            withAnimation{
                                if offset.height > 85 {
                                    viewModel.showPostView = false
                                    offset = .zero
                                    viewModel.mapSelection = nil
                                } else {
                                    offset = .zero
                                }
                            }
                        })
                )
                .onAppear(){
                    reverseGeocode(coordinate: CLLocationCoordinate2D(latitude: viewModel.selectedPost.location.latitude, longitude: viewModel.selectedPost.location.longitude)) { result in
                        address = result
                    }
                }
            }
            
            
        }
    }
    
    func setLocation(cameraPosition: Binding<MapCameraPosition>, span: CLLocationDegrees) {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        if let userLocation = locationManager.location?.coordinate {
            cameraPosition.wrappedValue = .region(MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
            ))
        }
    }

    
}


struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(PostsViewModel())
            .environmentObject(UserViewModel())
    }
}
