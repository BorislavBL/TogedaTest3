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
    
    @EnvironmentObject var locationManager: LocationManager
//    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    ))
    @State private var mapSelection: Post?
    @State private var showPostView: Bool = false
    @State private var selectedPost: Post = Post.MOCK_POSTS[0]
    @Namespace private var locationSpace
    @State private var visibleRegion: MKCoordinateRegion?
    
    @State private var searchText: String = ""
    @State private var searchResults: [Post] = Post.MOCK_POSTS.filter{$0.accessability == Visabilities.Public}
    @State var showSearch: Bool = false
    
    @State private var address: String?
    
    @EnvironmentObject var postsViewModel: PostsViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @State var mapPosts: [Post] = Post.MOCK_POSTS.filter{$0.accessability == Visabilities.Public}
    
    @StateObject var filterViewModel = FilterViewModel()
    //    @StateObject var viewModel = MapViewModel()
    @State private var isInitialLocationSet = false
    
    var body: some View {
        //        UIMap()
        //            .edgesIgnoringSafeArea(.top)
        
        ZStack(alignment: .top){
            Map(position: $cameraPosition, interactionModes: [.zoom, .pan], selection: $mapSelection, scope: locationSpace) {
                
                ForEach(mapPosts, id: \.id) { post in
                    
                    Marker(post.title, coordinate: CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude))
                        .tag(post)
                        .tint(.black)
                    
                }
                
                UserAnnotation()
            }
            .onMapCameraChange { context in
                visibleRegion = context.region
            }
            .onAppear(){
                if !isInitialLocationSet {
                    setLocation(cameraPosition: $cameraPosition, span: 0.1)
                    isInitialLocationSet = true
                }
            }
            .overlay(alignment: .bottomTrailing) {
                VStack(spacing: 15){
                    MapCompass(scope: locationSpace)
                    //                    MapPitchToggle(scope: locationSpace)
                    Button {
                        if let region = visibleRegion {
                            mapPosts = self.postsViewModel.posts.filter{
                                isLocationInsideVisibleRegion(latitude: $0.location.latitude, longitude: $0.location.longitude, region: region)
                            }
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
                            ForEach(searchResults, id:\.id){ post in
                                Button {
                                    searchText = ""
                                    UIApplication.shared.endEditing(true)
                                    withAnimation(.snappy){
                                        cameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude), latitudinalMeters: 5000, longitudinalMeters: 5000))
                                        mapSelection = post
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
                    .padding(.top, 95)
                    .padding(.vertical)
                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
                    .background()
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .mapControls{}
            .mapScope(locationSpace)
            //            .navigationTitle("Map")
            //            .navigationBarTitleDisplayMode(.inline)
            //            .searchable(text: $searchText, isPresented: $showSearch, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: searchText){
                if !searchText.isEmpty {
                    mapSelection = nil
                    searchResults = mapPosts.filter{ result in
                        result.title.lowercased().contains(searchText.lowercased())
                    }
                } else {
                    searchResults = mapPosts
                }
            }
            .onChange(of: mapSelection, { oldValue, newValue in
                if let post = newValue {
                    reverseGeocode(coordinate: CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude)) { result in
                        address = result
                    }
                    
                    withAnimation(.linear) {
                        selectedPost = post
                        showPostView = true
                    }
                    
                } else {
                    withAnimation(.linear) {
                        showPostView = false
                    }
                    
                }
            })
            .onSubmit(of: .search) {
                Task {
                    guard !searchText.isEmpty else {return}
                    print("submit")
                }
            }
            
            
            MapNavBar(searchText: $searchText, showSearch: $showSearch, viewModel: filterViewModel)
        }
        .sheet(isPresented: $filterViewModel.filterIsSelected) {
            FilterView(filterViewModel: filterViewModel)
        }
        .overlay(alignment:.bottom) {
            if showPostView && !showSearch {
//                Button {
//                    print("Clicked")
//                    showPostView = false
//                    postsViewModel.showDetailsPage = true
//                    postsViewModel.clickedPostIndex = postsViewModel.posts.firstIndex(of: selectedPost) ?? 0
//                } label: {
//                    EventMapPreview(post: selectedPost, address: address)
//                }
                NavigationLink(value: selectedPost.id){
                    EventMapPreview(post: selectedPost, address: address)
                }
                .frame(height: 170)
                .frame(maxWidth: UIScreen.main.bounds.width, alignment: .leading)
                .background(.bar)
                .cornerRadius(20)
                .padding(8)
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                .onAppear(){
                    reverseGeocode(coordinate: CLLocationCoordinate2D(latitude: selectedPost.location.latitude, longitude: selectedPost.location.longitude)) { result in
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

extension CLLocationCoordinate2D {
    static var myLocation: CLLocationCoordinate2D {
        return .init(latitude: 42.697463, longitude: 23.320301)
    }
}

extension MKCoordinateRegion {
    static var myRegion: MKCoordinateRegion {
        return .init(center: .myLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(PostsViewModel())
            .environmentObject(UserViewModel())
    }
}
