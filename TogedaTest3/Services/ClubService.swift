//
//  ClubService.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 20.02.24.
//

import Foundation

class ClubService {
    static let shared = ClubService()
    
    func createClub(clubData: CreateClub) async throws {
        guard let encoded = try? JSONEncoder().encode(clubData) else {
            throw GeneralError.encodingError
        }
        
        guard let url = URL(string: "https://api.togeda.net/clubs") else {
            throw GeneralError.invalidURL
        }
        
        guard let accessToken = KeychainManager.shared.getTokenToString(item: userKeys.accessToken.toString, service: userKeys.service.toString) else {
            print("No access token available")
            throw GeneralError.keyChainError
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: encoded)
//        print(String(data: data, encoding: .utf8))
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeneralError.noHTTPResponse
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            if let loginErrorResponse = try? JSONDecoder().decode(APIErrorResponse1.self, from: data) {
                throw GeneralError.badRequest(details: loginErrorResponse.apierror.message)
                
            } else {
                throw GeneralError.serverError(statusCode: httpResponse.statusCode, details: "Server responded with status code: \(httpResponse.statusCode)")
            }
        }
        
        do {
            let decodedUsers = try JSONDecoder().decode(createClubResponse.self, from: data)
            print(decodedUsers)
        } catch {
            throw GeneralError.decodingError
        }
        
    }
    
    struct createClubResponse: Codable {
        let success: Bool
    }
}
