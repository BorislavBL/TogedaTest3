//
//  AuthService.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 29.01.24.
//

import Foundation

enum GeneralError: Error {
    case encodingError
    case invalidURL
    case noHTTPResponse
    case badRequest(details: String)
    case serverError(statusCode: Int, details: String)
    case decodingError
}

struct APIErrorResponse: Codable {
    let apierror: APIError
}

struct APIError: Codable {
    let status: String
    let timestamp: String
    let message: String
    let debugMessage: String?
    let subErrors: String? // Adjust types if necessary
}

class AuthService {
    @Published var userID: String?
    
    func login(email: String, password: String) async throws {
        guard let url = URL(string: "https://api.togeda.net/login?email=\(email)&password=\(password)") else {
            throw GeneralError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            let authResult = loginResponse.authenticationResult
            let requestId = loginResponse.sdkResponseMetadata.requestId
            
            // Save or use the tokens as needed
            print("Access Token: \(authResult.accessToken)")
            print("Refresh Token: \(authResult.refreshToken)")
            print("ID Token: \(authResult.idToken)")
            print("Request ID: \(requestId)")
            
            if let accessTokenData = authResult.accessToken.data(using: .utf8) {
                let saved = KeychainManager().saveOrUpdate(item: accessTokenData, account: "userAccessToken", service: "net-togeda-app")
                print(saved ? "Token saved/updated successfully" : "Failed to save/update token")
            }
            
            if let refreshTokenData = authResult.refreshToken.data(using: .utf8) {
                let saved = KeychainManager().saveOrUpdate(item: refreshTokenData, account: "userRefreshToken", service: "net-togeda-app")
                print(saved ? "Token saved/updated successfully" : "Failed to save/update token")
            }
            
            if let requestIdData = requestId.data(using: .utf8) {
                let saved = KeychainManager().saveOrUpdate(item: requestIdData, account: "userId", service: "net-togeda-app")
                print(saved ? "Token saved/updated successfully" : "Failed to save/update token")
            }
            
        } catch {
            throw GeneralError.decodingError
        }
    }
    
    struct AuthenticationResult: Codable {
        let accessToken: String
        let refreshToken: String
        let idToken: String
    }
    
    struct SDKResponseMetadata: Codable {
        let requestId: String
    }
    
    struct LoginResponse: Codable {
        let sdkResponseMetadata: SDKResponseMetadata
        let authenticationResult: AuthenticationResult
    }
    
    
    func confirmSignUp(userId: String, code: Int) async throws {
        print("userID:\(userId), code:\(code)")
        guard let url = URL(string: "https://api.togeda.net/confirmSignUp?userId=\(userId)&confirmationCode=\(code)") else {
            throw GeneralError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
    }
    
    
    
    func createUser(userData: CreateUser) async throws -> String? {
        guard let encoded = try? JSONEncoder().encode(userData) else {
            throw GeneralError.encodingError
        }
        
        guard let url = URL(string: "https://api.togeda.net/signUp") else {
            throw GeneralError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
            let decodedUsers = try JSONDecoder().decode(CreateUserResponse.self, from: data)
            print(decodedUsers)
            return decodedUsers.userId
        } catch {
            throw GeneralError.decodingError
        }
        
    }
    
    struct CreateUserResponse: Codable {
        let userId: String
    }
    
    func resendSignUpCode(email: String) async throws {
        guard let url = URL(string: "https://api.togeda.net/resendPhoneConfirmationCode?email=\(email)") else {
            throw GeneralError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
    }
    
    func userExistsWithEmail(email: String) async throws -> Bool {
        guard let url = URL(string: "https://api.togeda.net/userExistsWithEmail?email=\(email)") else {
            throw GeneralError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                // Handle non-2xx responses here, potentially decoding an error response
                throw GeneralError.noHTTPResponse // Or a more specific error based on the statusCode
            }
            
            // Decode the JSON to a [String: Bool] dictionary
            let decodedResponse = try JSONDecoder().decode([String: Bool].self, from: data)
            
            // Attempt to retrieve the boolean value using the email as the key
            if let exists = decodedResponse[email] {
                return exists
            } else {
                // Handle the case where the email key is not found in the response
                throw GeneralError.badRequest(details: "Email key not found in response")
            }
        } catch {
            // Handle any decoding errors or other errors
            throw error
        }
    }

}
