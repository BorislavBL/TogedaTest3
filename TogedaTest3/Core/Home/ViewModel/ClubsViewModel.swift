//
//  ClubsViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 14.06.24.
//

import Foundation
import Combine
import MapKit
import SwiftUI

class ClubsViewModel: ObservableObject {
    @Published var feedClubs: [Components.Schemas.ClubDto] = []
    @Published var lastPage: Bool = true
    @Published var clubsFeedIsLoading = false
    @Published var feedClubsInit: Bool = true
    
    @Published var page: Int32 = 0
    @Published var size: Int32 = 15
    
    @Published var lat: Double = 43
    @Published var long: Double = 39
    @Published var distance: Int = 300
    @Published var categories: [String]? = nil
    @Published var clickedClub: Components.Schemas.ClubDto = MockClub
    @Published var showShareClubSheet: Bool = false
    @Published var showJoinClubSheet: Bool = false
    
    @Published var showOption: Bool = false
    @Published var showReport: Bool = false
    
    private var locationCancellables = Set<AnyCancellable>()
    private var locationManager = LocationManager()
    
    init() {
        locationManager.$location
            .compactMap { $0 } // Ensure the location is not nil
            .first() // Take only the first non-nil location
            .sink { [weak self] location in
                guard let self = self else { return }
                DispatchQueue.main.async{
                    self.lat = location.coordinate.latitude
                    self.long = location.coordinate.longitude
                }
            }
            .store(in: &locationCancellables)
    }
    
    func fetchClubs() async throws {
//        print("club Page: \(page), Seize: \(size), Cord: \(lat), \(long), Distance: \(distance)")
        DispatchQueue.main.async {
            self.clubsFeedIsLoading = true
        }
        if let response = try await APIClient.shared.getAllClubs(
            page: page,
            size: size,
            long: long,
            lat: lat,
            distance: Int32(distance),
            categories: categories
            ) {
            
            DispatchQueue.main.async{
                self.feedClubs += response.data
                self.lastPage = response.lastPage
                if !response.lastPage {
                    self.page += 1
                }
                self.clubsFeedIsLoading = false
                self.feedClubsInit = false
            }
        }
    }
    
    func refreshClubOnActionAsync(clubId: String) async throws {
        if let response = try await APIClient.shared.getClub(clubID: clubId) {
            if let index = feedClubs.firstIndex(where: { $0.id == clubId }) {
                DispatchQueue.main.async{
                    self.feedClubs[index] = response
                }
            }
        }
        
    }
    
    func refreshClubOnAction(club: Components.Schemas.ClubDto){
        if let index = feedClubs.firstIndex(where: { $0.id == club.id }) {
            DispatchQueue.main.async{
                self.feedClubs[index] = club
            }
        }
    }
    
    func applyFilter(lat: Double, long: Double, distance: Int, categories: [String]?) async throws {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async{
                self.page = 0
                self.feedClubs = []
                self.lastPage = true
                
                self.lat = lat
                self.long = long
                self.distance = distance
                self.categories = categories
                continuation.resume()
            }
        }
        
        try await self.fetchClubs()
        
    }
    
    
    func feedScrollFetch(index: Int) {
        if !lastPage {
            if index == feedClubs.count - 7 {
                Task{
                   try await self.fetchClubs()
                }
            }
        }
    }
    
    func deleteClub(clubId: String) async throws {
        Task{
            if try await APIClient.shared.deleteClub(clubId: clubId) != nil {
                if let index = feedClubs.firstIndex(where: { $0.id == clubId }) {
                    DispatchQueue.main.async {
                        self.feedClubs.remove(at: index)
                    }
                }
            }
        }
    }
    
    func clubUpdateOnNewNotification(notification: Components.Schemas.NotificationDto) {
        if let not = notification.alertBodyAcceptedJoinRequest{
            if let club = not.club {
                if let index = self.feedClubs.firstIndex(where: {$0.id == club.id}){
                    self.feedClubs[index] = transferStatusDataFromMiniToNormalClub(miniClub: club, club:  self.feedClubs[index])
                }
            }
        }
    }
    
    func transferStatusDataFromMiniToNormalClub(miniClub: Components.Schemas.MiniClubDto, club:Components.Schemas.ClubDto) -> Components.Schemas.ClubDto {
        var newClub = club
        var currentUserStatus = miniClub.currentUserStatus.rawValue
        newClub.currentUserStatus = .init(rawValue: currentUserStatus) ?? club.currentUserStatus
        if let currentUserRole = miniClub.currentUserRole?.rawValue {
            newClub.currentUserRole = .init(rawValue: currentUserRole)
        }
        return newClub
    }
    
}
