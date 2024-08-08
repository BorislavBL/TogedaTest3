//
//  FriendsFeedView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 9.07.24.
//

import SwiftUI

struct FriendsFeedView: View {
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
                    
                    ActivityPostCell(post: MockPost)
                    ClubCellActivity(club: MockClub)
                    
                }
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
                    
                    done()
                }
                
            }
            .onChange(of: navManager.homeScrollTop) {
                if viewModel.showCancelButton {
                    viewModel.showCancelButton = false
                } else {
                    if filterViewModel.selectedType == .friends{
                        withAnimation {
                            proxy.scrollTo("Top", anchor: .top)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    FriendsFeedView(showFilter: .constant(false), filterViewModel: FilterViewModel(), viewModel: HomeViewModel())
        .environmentObject(LocationManager())
        .environmentObject(PostsViewModel())
        .environmentObject(ClubsViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(NavigationManager())
}
