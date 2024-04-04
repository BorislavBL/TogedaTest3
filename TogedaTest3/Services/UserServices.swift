//
//  UserServices.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation

class UserService: ObservableObject {
    func fetchUserDetails(userId: String) async throws -> User {
        guard let url = URL(string: "https://api.togeda.net/users/\(userId)") else {
            throw GeneralError.invalidURL
        }
        
        guard let accessToken = KeychainManager.shared.getTokenToString(item: userKeys.accessToken.toString, service: userKeys.service.toString) else {
            print("No access token available")
            throw GeneralError.keyChainError
        }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeneralError.noHTTPResponse
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            if let loginErrorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw GeneralError.badRequest(details: loginErrorResponse.apierror.message)
            } else {
                throw GeneralError.serverError(statusCode: httpResponse.statusCode, details: "Server responded with status code: \(httpResponse.statusCode)")
            }
        }
        
        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            return user
        } catch {
            // Handle any decoding errors or other errors
            throw error
        }
    }
    
    func editUserDetails(userData: EditUser?, phoneNumber: String?) async throws -> Bool {
        guard userData != nil || phoneNumber != nil else {
            throw GeneralError.encodingError
        }

        let encoded: Data
        if let userData = userData {
            encoded = try JSONEncoder().encode(userData)
        } else if let phoneNumber = phoneNumber {
            encoded = try JSONEncoder().encode(ChangePhoneNumber(phoneNumber: phoneNumber))
        } else {
            encoded = try JSONEncoder().encode(userData!)
        }
        
        guard let accessToken = KeychainManager.shared.getTokenToString(item: userKeys.accessToken.toString, service: userKeys.service.toString) else {
            print("No access token available")
            throw GeneralError.keyChainError
        }
        
        guard let userId = KeychainManager.shared.getTokenToString(item: userKeys.userId.toString, service: userKeys.service.toString) else {
            print("No userId available")
            throw GeneralError.keyChainError
        }
        
        guard let url = URL(string: "https://api.togeda.net/users/\(userId)") else {
            throw GeneralError.invalidURL
        }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: encoded)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeneralError.noHTTPResponse
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            if let loginErrorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw GeneralError.badRequest(details: loginErrorResponse.apierror.message)
            } else {
                throw GeneralError.serverError(statusCode: httpResponse.statusCode, details: "Server responded with status code: \(httpResponse.statusCode)")
            }
        }
        
        do {
            let responseData = try JSONDecoder().decode(SuccessResponse.self, from: data)
            return responseData.success
        } catch {
            print(error)
            return false
        }
    }
    
    struct ChangePhoneNumber: Codable, Hashable {
        var phoneNumber: String
    }
    
    struct SuccessResponse: Codable {
        let success: Bool
    }
    
}
