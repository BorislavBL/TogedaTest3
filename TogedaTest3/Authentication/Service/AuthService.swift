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
            
            // Example of how you might save these tokens
            // UserDefaults.standard.set(authResult.accessToken, forKey: "accessToken")
            // UserDefaults.standard.set(authResult.refreshToken, forKey: "refreshToken")
            // UserDefaults.standard.set(authResult.idToken, forKey: "idToken")
            // UserDefaults.standard.set(requestId, forKey: "requestId")
            
        } catch {
            throw GeneralError.decodingError
        }
    }
    
    struct APIError: Codable {
        let status: String
        let timestamp: String
        let message: String
        let debugMessage: String?
        let subErrors: String? // Adjust types if necessary
    }
    
    struct APIErrorResponse: Codable {
        let apierror: APIError
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
    
    
    func uploadFile(to presignedUrl: String, filePath: String) {
        guard let fileURL = URL(string: filePath) else {
            print("Invalid file URL")
            return
        }
        
        var request = URLRequest(url: URL(string: presignedUrl)!)
        request.httpMethod = "PUT"
        
        do {
            let fileData = try Data(contentsOf: fileURL)
            
            let task = URLSession.shared.uploadTask(with: request, from: fileData) { (data, response, error) in
                if let error = error {
                    print("Error uploading file: \(error)")
                } else {
                    print("File uploaded successfully")
                }
            }
            
            task.resume()
        } catch {
            print("Error reading file data: \(error)")
        }
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
}
