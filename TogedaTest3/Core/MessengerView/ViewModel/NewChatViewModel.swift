//
//  NewChatViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 29.11.23.
//

import Foundation
import PhotosUI
import SwiftUI

class NewChatViewModel: ObservableObject {
    @Published var participants: [Components.Schemas.MiniUser] = []
    @Published var groupName: String = ""
    @Published var groupImage: Image?
    @Published var showPhotosPicker = false
    @Published var selectedItem: PhotosPickerItem? = nil {
        didSet {
            setImage(from: selectedItem)
        }
    }
    
    @Published var searchedFriends: [Components.Schemas.MiniUser] = []
    @Published var searchText: String = ""
    @Published var lastPage = true
    @Published var page: Int32 = 0
    @Published var pageSize: Int32 = 15
    func searchUsers() async throws{
        Task{
            if let response = try await APIClient.shared.searchFriends(
                searchText: searchText,
                page: page,
                size: pageSize
            )
            {
                
                DispatchQueue.main.async { [weak self] in
                    self?.searchedFriends += response.data
                    self?.lastPage = response.lastPage
                    self?.page += 1
                }
            }
        }
    }
    
    func setImage(from selection: PhotosPickerItem?){
        guard let selection else {return}
        
        Task {
            
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                
                await MainActor.run {
                    groupImage = Image(uiImage: uiImage)
                }
                
            } catch {
                print(error)
            }
        }
    }
    
}
