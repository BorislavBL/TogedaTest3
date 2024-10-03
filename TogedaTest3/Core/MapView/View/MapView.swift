//
//  MapView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 19.09.23.
//

//import ClusterMap
//import ClusterMapSwiftUI
import SwiftUI
import MapKit
import Kingfisher

struct MapView: View {
    @StateObject var viewModel = MapViewModel()
    @EnvironmentObject var locationManager: LocationManager
    @Namespace private var locationSpace
    
    @State var showSearch: Bool = false
    
    @StateObject var filterViewModel = FilterViewModel()
    
    @State private var isInitialLocationSet = false
    
    @State private var offset = CGSize.zero
    var body: some View {
        ZStack(alignment: .top){
            Map(position: $viewModel.cameraPosition, interactionModes: [.zoom, .pan], selection: $viewModel.mapSelection, scope: locationSpace) {
                
//                                ForEach(viewModel.mapPosts, id: \.id) { post in
//                
////                                                        Marker(post.title, coordinate: CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude))
////                                                            .tag(post)
////                                                            .tint(.black)
//                
//                                    Annotation("", coordinate: CLLocationCoordinate2D(latitude: post.location.latitude, longitude: post.location.longitude)) {
//                                        annotationPost(item: post)
//                                    }
//                                    .tag(post.id)
//                
//                
//                                }
                
                ForEach(viewModel.annotations) { item in
                    Annotation("", coordinate: CLLocationCoordinate2D(latitude: item.coordinate.latitude, longitude: item.coordinate.longitude)) {
                        annotation(item: item)
                    }
                    .tag(item.postID)
                    .annotationTitles(.hidden)
                }
                ForEach(viewModel.clusters) { item in
                    Annotation("", coordinate: CLLocationCoordinate2D(latitude: item.coordinate.latitude, longitude: item.coordinate.longitude)) {
                        clusteringAnnotation(item: item)
                    }
                    .tag(item.postID)
                    .annotationTitles(.hidden)
                }
                UserAnnotation()
            }
            .readSize(onChange: { newValue in
                viewModel.mapSize = newValue
            })
            .onMapCameraChange { context in
                viewModel.visibleRegion = context.region
            }
            .onAppear(){
                if !isInitialLocationSet {
                    setLocation()
                    isInitialLocationSet = true
                }
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                Task.detached {
                    await viewModel.reloadAnnotations()
                }
            }
            .overlay(alignment: .bottomTrailing) {
                VStack(spacing: 15){
                    MapCompass(scope: locationSpace)
                    //                    MapPitchToggle(scope: locationSpace)
                    Button {
                        Task{
                            do {
                                if let region = viewModel.visibleRegion{
                                    try await viewModel.getCurrentAreaPosts(region: region)
                                }
                            } catch {
                                print("Error map fetch", error.localizedDescription)
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
                            ForEach(viewModel.places, id:\.id){ place in
                                Button {
                                    Task{
                                        viewModel.searchText = ""
                                        UIApplication.shared.endEditing(true)
                                        
                                        let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
                                        
                                        let coordinatedRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                                        
                                        try await viewModel.getCurrentAreaPosts(region: coordinatedRegion)
                                        
                                        withAnimation(.snappy){
                                            viewModel.cameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude), latitudinalMeters: 5000, longitudinalMeters: 5000))
                                            //                                            viewModel.mapSelection = post
                                        }
                                        
                                        showSearch = false
                                    }
                                } label: {
                                    HStack{
                                        Image(systemName: "mappin.circle.fill")
                                            .font(.body)
                                            .foregroundColor(.gray)
                                        
                                        VStack(alignment: .leading) {
                                            Text(place.name)
                                                .font(.body)
                                                .fontWeight(.semibold)
                                            
                                            if !place.address.isEmpty {
                                                Text(place.address)
                                                    .font(.callout)
                                            }
                                        }
                                        
                                    }
                                    .padding(.horizontal)
                                }
                                Divider()
                            }
                            
                        }
                        
                    }
                    .padding(.top, 60)
                    .padding(.vertical)
                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
                    .background(.bar)
                }
            }
            .ignoresSafeArea(.keyboard)
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .mapControls{}
            .mapScope(locationSpace)
            //            .navigationTitle("Map")
            //            .navigationBarTitleDisplayMode(.inline)
            //            .searchable(text: $searchText, isPresented: $showSearch, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: viewModel.mapSelection, { oldValue, newValue in
                if let id = newValue {
                    withAnimation(.linear) {
                        if let post = viewModel.searchForPost(id: id){
                            viewModel.selectedPost = post
                            viewModel.showPostView = true
                        }
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
            
            
            MapNavBar(searchText: $viewModel.searchText, showSearch: $showSearch)
//            
        }
//                .sheet(isPresented: $filterViewModel.showAllFilter){
//                    AllInOneFilterView(filterVM: filterViewModel)
//        //                .presentationDetents([.fraction(0.99)])
//        //                .presentationDragIndicator(.visible)
//                }
        .onChange(of: showSearch){
            if showSearch {
                viewModel.startSearch()
            } else {
                viewModel.stopSearch()
            }
        }
        .overlay(alignment:.bottom) {
            if viewModel.showPostView && !showSearch {
                NavigationLink(value: SelectionPath.eventDetails(viewModel.selectedPost)){
                    EventMapPreview(post: viewModel.selectedPost)
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
            }
            
            
        }
    }
    
    func setLocation() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let userLocation = locationManager.location?.coordinate {
            let coordinatedRegion = MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
            viewModel.cameraPosition = .region(coordinatedRegion)
            
            Task{
                do {
                    print("fetch")
                    try await viewModel.getCurrentAreaPosts(region: coordinatedRegion)
                } catch {
                    print("Error map fetch", error.localizedDescription)
                }
            }
            
        }
    }
    
    @ViewBuilder
    func annotation(item: MapAnnotation) -> some View {
            VStack{
                ZStack(alignment: .bottom){
                    Rectangle()
                        .rotation(.degrees(45))
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                        .offset(y:5)

                    KFImage(URL(string: item.image))
                        .resizable()
                        .scaledToFill()
                        .frame(width: viewModel.mapSelection == item.postID ? 60 : 44, height: viewModel.mapSelection == item.postID ? 60 : 44)
                        .background(.gray)
                        .clipShape(.circle)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                }


                Text(item.name)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .frame(width: 110)
                    .lineLimit(1)
            }
            .offset(y: viewModel.mapSelection == item.postID ? -30 : -22 )
            .scaleEffect(viewModel.mapSelection == item.postID ? 1.2 : 1.0) // Scale the entire ZStack based on selection
            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: viewModel.mapSelection)
        
    }
    
    func clusteringAnnotation(item: MapClusterAnnotation) -> some View {
            VStack{
                ZStack(alignment: .bottom){
                    Rectangle()
                        .rotation(.degrees(45))
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                        .offset(y:5)

                    KFImage(URL(string: item.image))
                        .resizable()
                        .scaledToFill()
                        .frame(width: viewModel.mapSelection == item.postID ? 60 : 44, height: viewModel.mapSelection == item.postID ? 60 : 44)
                        .background(.gray)
                        .clipShape(.circle)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                }

                VStack(alignment: .center, spacing: 0){
                    Text("\(item.name)")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .frame(width: 110)
                        .lineLimit(1)
                    
                    Text("+ \(formatBigNumbers(item.count - 1)) more")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .frame(width: 110)
                        .lineLimit(1)
                }
            }
            .offset(y: viewModel.mapSelection == item.postID ? -30 : -22 )
            .scaleEffect(viewModel.mapSelection == item.postID ? 1.2 : 1.0) // Scale the entire ZStack based on selection
            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: viewModel.mapSelection)
        
    }
    
    func annotationPost(item: Components.Schemas.PostResponseDto) -> some View {
            VStack{
                ZStack(alignment: .bottom){
                    Rectangle()
                        .rotation(.degrees(45))
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                        .offset(y:5)

                    KFImage(URL(string: item.images[0]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: viewModel.mapSelection == item.id ? 60 : 44, height: viewModel.mapSelection == item.id ? 60 : 44)
                        .background(.gray)
                        .clipShape(.circle)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                }
                .offset(y: viewModel.mapSelection == item.id ? -30 : -22 )


                Text(item.title)
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .fontWeight(.semibold)
            }

            .scaleEffect(viewModel.mapSelection == item.id ? 1.2 : 1.0) // Scale the entire ZStack based on selection
            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: viewModel.mapSelection)
        
    }
}


struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(PostsViewModel())
            .environmentObject(UserViewModel())
    }
}
