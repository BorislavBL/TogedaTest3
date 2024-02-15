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
    case keyChainError
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

class AuthService: ObservableObject {
    
    static let shared = AuthService()
    
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
    
    
    func refreshToken() async throws {
        guard let refreshToken = KeychainManager.shared.getTokenToString(item: userKeys.refreshToken.toString, service: userKeys.service.toString) else {
            print("Failed to get Refresh Token")
            throw GeneralError.keyChainError
        }
        
        guard let userId = KeychainManager.shared.getTokenToString(item: userKeys.userId.toString, service: userKeys.service.toString) else {
            print("Failed to get user id")
            throw GeneralError.keyChainError
        }
        
        guard let url = URL(string: "https://api.togeda.net/refreshToken?refreshToken=\(refreshToken)&userId=\(userId)") else {
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
            let response = try JSONDecoder().decode(RefreshTokenResponse.self, from: data)
            
            // Save or use the tokens as needed
            print("Access Token: \(response.accessToken)")
            
            if let accessTokenData = response.accessToken.data(using: .utf8) {
                let saved = KeychainManager.shared.saveOrUpdate(item: accessTokenData, account: userKeys.accessToken.toString, service: userKeys.service.toString)
                print(saved ? "Token saved/updated successfully" : "Failed to save/update token")
                
                if let tokenString = String(data: accessTokenData, encoding: .utf8) {
                    let token = KeychainManager.shared.getDecodedJWTBody(token: tokenString)
                    if let userIdData = token?.username.data(using: .utf8) {
                        let savedUserIdData = KeychainManager.shared.saveOrUpdate(item: userIdData, account: userKeys.userId.toString, service: userKeys.service.toString)
                        print(savedUserIdData ? "Token saved/updated successfully" : "Failed to save/update token")
                    }
                }
            }
            
        } catch {
            throw GeneralError.decodingError
        }
    }
    
    struct RefreshTokenResponse: Codable {
        let idToken: String
        let accessToken: String
    }

}


extension AuthService {
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
            let authResult = loginResponse.authResult.authenticationResult
            let userId = loginResponse.userId
            
            // Save or use the tokens as needed
            print("Access Token: \(authResult.accessToken)")
            print("Refresh Token: \(authResult.refreshToken)")
            print("ID Token: \(authResult.idToken)")
            print("userId: \(userId)")
            
            if let accessTokenData = authResult.accessToken.data(using: .utf8) {
                let saved = KeychainManager.shared.saveOrUpdate(item: accessTokenData, account: userKeys.accessToken.toString, service: userKeys.service.toString)
                print(saved ? "Token saved/updated successfully" : "Failed to save/update token")
            }
            
            if let refreshTokenData = authResult.refreshToken.data(using: .utf8) {
                let saved = KeychainManager.shared.saveOrUpdate(item: refreshTokenData, account: userKeys.refreshToken.toString, service: userKeys.service.toString)
                print(saved ? "Token saved/updated successfully" : "Failed to save/update token")
            }
            
            if let userIdData = userId.data(using: .utf8) {
                let saved = KeychainManager.shared.saveOrUpdate(item: userIdData, account: userKeys.userId.toString, service: userKeys.service.toString)
                print(saved ? "Token saved/updated successfully" : "Failed to save/update token")
            }
                        
        } catch {
            throw GeneralError.decodingError
        }
    }
    
    struct LoginResponse: Codable {
        let authResult: AuthResult
        let userId: String
    }

    struct AuthResult: Codable {
        let authenticationResult: AuthenticationResult
    }

    struct AuthenticationResult: Codable {
        let accessToken: String
        let expiresIn: Int
        let tokenType: String
        let refreshToken: String
        let idToken: String
    }
}

