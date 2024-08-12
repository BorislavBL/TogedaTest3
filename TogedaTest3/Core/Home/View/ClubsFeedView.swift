//
//  ClubsFeedView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.07.24.
//

import SwiftUI

struct ClubsFeedView: View {
    @EnvironmentObject var clubsVM: ClubsViewModel
    @State var isLoading: Bool = false
    @State private var previousMinY: CGFloat = 0
    @Binding var showFilter: Bool
    @ObservedObject var filterViewModel: FilterViewModel
    @EnvironmentObject var navManager: NavigationManager
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false){
                LazyVStack (spacing: 10){
                    Color.clear
                        .frame(height: 74)
                        .id("Top")
                    
                    if filterViewModel.updateClubs {
                        updateLocationButton()
                    }
                    
                    if clubsVM.feedClubs.count > 0 {
                        ForEach(Array(clubsVM.feedClubs.enumerated()), id: \.element.id) {index, club in
                            ClubCell(club: club)
                            //                                            .id(club.id)
                                .onAppear(){
                                    clubsVM.feedScrollFetch(index: index)
                                }
                        }
                        
                        if isLoading {
                            PostSkeleton() // Show spinner while loading
                        } else if clubsVM.lastPage{
                            VStack(spacing: 8){
                                Divider()
                                Text("No more clubs")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.gray)
                                
                            }
                            .padding()
                        }
                        
                    } else if clubsVM.clubsFeedIsLoading {
                        ForEach(0..<5, id: \.self) { index in
                            PostSkeleton()
                        }
                    } else if !clubsVM.feedClubsInit{
                        VStack(spacing: 15){
                            Image(systemName: "doc.text.magnifyingglass")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .foregroundStyle(.gray)
                            
                            Text("No clubs currently in this area. \n Create one yourself!")
                                .font(.body)
                                .foregroundStyle(.gray)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .padding(.bottom)
                            
                            Button {
                                navManager.isPresentingClub = true
                            } label: {
                                Text("Create Club")
                                    .font(.subheadline)
                                    .foregroundStyle(Color("base"))
                                    .fontWeight(.semibold)
                                    .frame(minWidth: 0, maxWidth: 200, alignment: .center)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 13)
                                    .background{Color("blackAndWhite")}
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.all)
                        .frame(maxHeight: .infinity, alignment: .center)
                    }
                    
                    
                    Rectangle()
                        .frame(width: 0, height: 0)
                        .onAppear {
                            if !clubsVM.lastPage {
                                isLoading = true
                                Task{
                                    try await clubsVM.fetchClubs()
                                    isLoading = false
                                    
                                }
                            }
                            
                            
                        }
                }
                //                        .padding(.top, navbarHeight - 20)
                .padding(.vertical)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .frame(width: 0, height: 0)
                            .onChange(of: geo.frame(in: .global).minY) { oldMinY,  newMinY in
                                if newMinY < previousMinY && showFilter && newMinY < 0 {
                                    DispatchQueue.main.async {
                                        withAnimation {
                                            showFilter = false
                                        }
                                    }
                                } else if newMinY > previousMinY && !showFilter{
                                    DispatchQueue.main.async {
                                        withAnimation {
                                            showFilter = true
                                        }
                                    }
                                }
                                
                                // Update the previous value
                                previousMinY = newMinY
                            }
                    }
                )
                
            }
            .refresher(config: .init(headerShimMaxHeight: 110), refreshView: HomeEmojiRefreshView.init) { done in
                Task{
                    try await refresh()

                    done()
                }
                
            }
            .onChange(of: navManager.homeScrollTop) {
                if viewModel.showCancelButton {
                    viewModel.showCancelButton = false
                } else {
                    if filterViewModel.selectedType == .clubs{
                        withAnimation {
                            proxy.scrollTo("Top", anchor: .top)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func updateLocationButton() -> some View {
        Button{
            Task{
                await withCheckedContinuation { continuation in
                    DispatchQueue.main.async{
                        clubsVM.long = filterViewModel.returnedPlace.longitude
                        clubsVM.lat = filterViewModel.returnedPlace.latitude
                        continuation.resume()
                    }
                }
                try await refresh()
                
                filterViewModel.updateClubs = false
            }
        } label:{
            Text("Update Location")
                .foregroundColor(Color("selectedTextColor"))
                .font(.footnote)
                .fontWeight(.bold)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background{Capsule().fill(Color("SelectedFilter"))}
        }
    }
    
    func refresh() async throws{
        clubsVM.feedClubs = []
        clubsVM.page = 0
        clubsVM.lastPage = true
        try await clubsVM.fetchClubs()
    }
}

#Preview {
    ClubsFeedView(showFilter: .constant(false), filterViewModel: FilterViewModel(), viewModel: HomeViewModel())
        .environmentObject(LocationManager())
        .environmentObject(PostsViewModel())
        .environmentObject(ClubsViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(NavigationManager())
}
