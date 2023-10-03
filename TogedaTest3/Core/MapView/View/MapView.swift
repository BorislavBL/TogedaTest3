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
    
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic) /*.region(.myRegion)*/
    @State private var mapSelection: Post?
    @Namespace private var locationSpace
    @State private var visibleRegion: MKCoordinateRegion?
    
    @State private var searchText: String = ""
    @State private var searchResults: [Post] = Post.MOCK_POSTS
    @State private var showSearch: Bool = false
    
    @State private var address: String?
    
    @ObservedObject var postsViewModel: PostsViewModel
    @ObservedObject var userViewModel: UserViewModel
    @State var mapPosts: [Post] = Post.MOCK_POSTS
    
    var body: some View {
        //        UIMap()
        //            .edgesIgnoringSafeArea(.top)
        NavigationStack{
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
                            .background(.bar)
                            .clipShape(Circle())
                    }
                    MapUserLocationButton(scope: locationSpace)
                }
                .buttonBorderShape(.circle)
                .padding()
            }
            .tint(.blue)
            .overlay{
                if showSearch && !searchText.isEmpty {
                    ScrollView{
                        LazyVStack(alignment: .leading, spacing: 10){
                            ForEach(searchResults, id:\.id){ post in
                                Button {
                                    searchText = ""
                                    showSearch = false
                                    withAnimation(.snappy){
                                        cameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude), latitudinalMeters: 500, longitudinalMeters: 500))
                                    }
                                } label: {
                                    Text(post.title)
                                        .padding(.vertical, 3)
                                        .padding(.horizontal)
                                }
                                Divider()
                            }
                            
                        }

                    }
                    .padding(.vertical)
                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
                    .background(.white)
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .mapControls{}
            .mapScope(locationSpace)
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, isPresented: $showSearch, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: searchText){
                if !searchText.isEmpty {
                    searchResults = searchResults.filter{ result in
                        result.title.lowercased().contains(searchText.lowercased())
                    }
                } else {
                    searchResults = Post.MOCK_POSTS
                }
            }
            .onSubmit(of: .search) {
                Task {
                    guard !searchText.isEmpty else {return}
                    print("submit")
                    searchText = ""
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let post = mapSelection{
                    Button {
                        postsViewModel.showDetailsPage = true
                        postsViewModel.clickedPostIndex = postsViewModel.posts.firstIndex(of: post) ?? 0
                    } label: {
                        HStack(alignment:.top, spacing: 10){
                            Image(post.imageUrl)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height:120)
                                .cornerRadius(10)
                                .clipped()
                            
                            VStack(alignment: .leading, spacing: 8){
                                Text(post.title)
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.leading)
                                
                                HStack(alignment: .center, spacing: 10) {
                                    HStack(alignment: .center, spacing: 5) {
                                        Text("\(separateDateAndTime(from: post.date).weekday), \(separateDateAndTime(from: post.date).date)")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .fontWeight(.bold)
                                        
                                        Text("at \(separateDateAndTime(from: post.date).time)")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .fontWeight(.bold)
                                    }
                                }
                                
                                Text(address ?? "")
                                    .font(.footnote)
                                    .foregroundStyle(.gray)
                                    .multilineTextAlignment(.leading)
                                    .onAppear(){
                                        reverseGeocode(coordinate: CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude)) { result in
                                            address = result
                                        }
                                    }
                                    .onChange(of: mapSelection){
                                        reverseGeocode(coordinate: CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude)) { result in
                                            address = result
                                        }
                                    }
                                
                                HStack(spacing: 30) {
                                    HStack(spacing: 3) {
                                        Image(systemName: "person.3")
                                            .foregroundStyle(.gray)
                                        Text("\(post.peopleIn.count)/\(post.maximumPeople)")
                                            .font(.footnote)
                                            .foregroundStyle(.gray)
                                            .multilineTextAlignment(.leading)
                
                                    }
                                    
                                    
                                    HStack(spacing: 3) {
                                        Image(systemName: "wallet.pass")
                                            .foregroundStyle(.gray)
                                        if post.payment <= 0 {
                                            Text("Free")
                                                .font(.footnote)
                                                .foregroundStyle(.gray)
                                                .multilineTextAlignment(.leading)
                                        } else {
                                            Text("$ \(String(format: "%.2f", post.payment))")
                                                .font(.footnote)
                                                .foregroundStyle(.gray)
                                                .multilineTextAlignment(.leading)
                                        }
                
                                    }
                                }
                                
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: UIScreen.main.bounds.width, alignment: .leading)
                    .background(.bar)
                    .cornerRadius(20)
                    .padding(8)
                }
            }
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
        MapView(postsViewModel: PostsViewModel(), userViewModel: UserViewModel())
    }
}
