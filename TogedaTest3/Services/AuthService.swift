//
//  AuthService.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 22.08.24.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes
import SwiftUI

class AuthService: ObservableObject {
    static let shared = AuthService()
    private var client: Client
    private let serverURL = URL(string: TogedaMainLinks.baseURL)!
    private weak var viewModel: ContentViewModel?
    
    private init() {
        client = Client(serverURL: serverURL, transport: URLSessionTransport())
    }
    
    func setViewModel(_ viewModel: ContentViewModel) {
        self.viewModel = viewModel
    }
    
//    @MainActor func handleAuthenticationFailure() {
//        viewModel?.checkAuthStatus()
//    }
    
}

//Authentication

extension AuthService {
    func resendEmailConfirmationCode(email: String) async throws -> Bool? {
        let response = try await client.resendEmailConfirmationCode(.init(query: .init(email: email)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code from chat:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for createChatForFriends")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Interna server error")
        }
        
        return nil
    }
    
    func userExistsWithEmail(email: String) async throws -> Bool? {
        let response = try await client.userExistsWithEmail(.init(query: .init(email: email)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code from chat:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for createChatForFriends")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Interna server error")
        }
        
        return nil
    }
    
    func signUp(email: String, password: String, completion: @escaping (String?, String?) -> Void) async throws {
        let response = try await client.signUp(.init(body: .json(.init(email: email, password: password))))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                completion(returnResponse.userId, nil)
            }
        case .undocumented(statusCode: let statusCode, _):
            completion(nil, "The status code: \(statusCode)")
        case .unauthorized(_):
            completion(nil, "Unauthorized")
        case .forbidden(_):
            completion(nil, "Forbidden")
        case .badRequest(let error):
            switch error.body {
            case .json(let error):
                let errorMessage = sanitizeMessage(errorHandler(error: error))
                completion(nil, errorMessage)
            }
        case .conflict(_):
            completion(nil, "Conflict")
        case .tooManyRequests(_):
            completion(nil, "Too many requests for addUserInfo")
        case .requestTimeout(_):
            completion(nil, "Request timeout")
        case .notFound(_):
            completion(nil, "Not found")
        case .internalServerError(let error):
            switch error.body {
            case .json(let error):
                print(error)
                let errorMessage = sanitizeMessage(errorHandler(error: error))
                completion(nil, errorMessage)
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Components.Schemas.LoginResponseDTO?, String?) -> Void) async throws {
        let response = try await client.login(.init(query: .init(email: email, password: password)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                completion(returnResponse, nil)
            }
        case .undocumented(statusCode: let statusCode, _):
            completion(nil, "The status code: \(statusCode)")
        case .unauthorized(_):
            completion(nil, "Unauthorized")
        case .forbidden(_):
            completion(nil, "Forbidden")
        case .badRequest(let error):
            switch error.body {
            case .json(let error):
                print("error", error)
                let errorMessage = errorHandler(error: error)
                completion(nil, errorMessage)
                print("errorMessage", errorMessage)

            }
        case .conflict(_):
            completion(nil, "Conflict")
        case .tooManyRequests(_):
            completion(nil, "Too many requests for addUserInfo")
        case .requestTimeout(_):
            completion(nil, "Request timeout")
        case .notFound(_):
            completion(nil, "Not found")
        case .internalServerError(let error):
            switch error.body {
            case .json(let error):
                let errorMessage = errorHandler(error: error)
                completion(nil, errorMessage)
            }
        }
    }
    
    func confirmSignUp(code: String, userId: String, completion: @escaping (Bool?, String?) -> Void) async throws {
        let response = try await client.confirmSignUp(query: .init(userId: userId, confirmationCode: code))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                completion(returnResponse.success, nil)
            }
        case .undocumented(statusCode: let statusCode, _):
            completion(nil, "The status code: \(statusCode)")
        case .unauthorized(_):
            completion(nil, "Unauthorized")
        case .forbidden(_):
            completion(nil, "Forbidden")
        case .badRequest(let error):
            switch error.body {
            case .json(let error):
                let errorMessage = errorHandler(error: error)
                completion(nil, errorMessage)
            }
        case .conflict(_):
            completion(nil, "Conflict")
        case .tooManyRequests(_):
            completion(nil, "Too many requests for addUserInfo")
        case .requestTimeout(_):
            completion(nil, "Request timeout")
        case .notFound(_):
            completion(nil, "Not found")
        case .internalServerError(let error):
            switch error.body {
            case .json(let error):
                let errorMessage = errorHandler(error: error)
                completion(nil, errorMessage)
            }
        }
    }
    
    func forgotPassword(email: String, completion: @escaping (Bool?, String?) -> Void) async throws {
        let response = try await client.forgotPassword(.init(query: .init(email: email)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                completion(returnResponse.success, nil)
            }
        case .undocumented(statusCode: let statusCode, _):
            completion(nil, "The status code: \(statusCode)")
        case .unauthorized(_):
            completion(nil, "Unauthorized")
        case .forbidden(_):
            completion(nil, "Forbidden")
        case .badRequest(let error):
            switch error.body {
            case .json(let error):
                let errorMessage = errorHandler(error: error)
                completion(nil, errorMessage)
            }
        case .conflict(_):
            completion(nil, "Conflict")
        case .tooManyRequests(_):
            completion(nil, "Too many requests for addUserInfo")
        case .requestTimeout(_):
            completion(nil, "Request timeout")
        case .notFound(_):
            completion(nil, "Not found")
        case .internalServerError(let error):
            switch error.body {
            case .json(let error):
                let errorMessage = errorHandler(error: error)
                completion(nil, errorMessage)
            }
        }
    }
    
    func refreshToken() async throws -> Bool {
        if let refreshToken = KeychainManager.shared.getTokenToString(item: userKeys.refreshToken.toString, service: userKeys.service.toString),
           let userId = KeychainManager.shared.getTokenToString(item: userKeys.userId.toString, service: userKeys.service.toString) {
            
            let response = try await client.refreshToken(.init(query: .init(refreshToken: refreshToken, userId: userId)))
            
            switch response {
            case .ok(let okResponse):
                switch okResponse.body{
                case .json(let returnResponse):
                    
                    let saved = KeychainManager.shared.saveOrUpdate(item: returnResponse.accessToken , account: userKeys.accessToken.toString, service: userKeys.service.toString)
                    let token = getDecodedJWTBody(token: returnResponse.accessToken )
                    if let userId = token?.username {
                        let savedUserIdData = KeychainManager.shared.saveOrUpdate(item: userId, account: userKeys.userId.toString, service: userKeys.service.toString)
                        print(savedUserIdData ? "Token saved/updated successfully" : "Failed to save/update token")
                    }
                    return true
                    
                }
            case .undocumented(statusCode: let statusCode, _):
                print("The status code from chat:", statusCode)
            case .unauthorized(_):
                print("Unauthorized")
            case .forbidden(_):
                print("Forbidden")
            case .badRequest(_):
                print("Bad Request")
            case .conflict(_):
                print("Conflict")
            case .tooManyRequests(_):
                print("To many Requests")
            case .requestTimeout(_):
                print("Requested timeout")
            case .notFound(_):
                print("Not found")
            case .internalServerError(_):
                print("Internal server error")
            }
        }
        return false
        
    }
    
    func confirmForgotPassword(userEmail: String, newPassword: String, code: String, completion: @escaping (Bool?, String?) -> Void) async throws {
        let response = try await client.confirmForgotPassword(.init(query: .init(userEmail: userEmail, newPassword: newPassword, confirmationCode: code)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                completion(returnResponse.success, nil)
            }
        case .undocumented(statusCode: let statusCode, _):
            completion(nil, "The status code: \(statusCode)")
        case .unauthorized(_):
            completion(nil, "Unauthorized")
        case .forbidden(_):
            completion(nil, "Forbidden")
        case .badRequest(let error):
            switch error.body {
            case .json(let error):
                let errorMessage = errorHandler(error: error)
                completion(nil, errorMessage)
            }
        case .conflict(_):
            completion(nil, "Conflict")
        case .tooManyRequests(_):
            completion(nil, "Too many requests for addUserInfo")
        case .requestTimeout(_):
            completion(nil, "Request timeout")
        case .notFound(_):
            completion(nil, "Not found")
        case .internalServerError(let error):
            switch error.body {
            case .json(let error):
                let errorMessage = errorHandler(error: error)
                completion(nil, errorMessage)
            }
        }
    }
    
    func clearSession() {
        let _ = KeychainManager.shared.delete(itemForAccount: userKeys.refreshToken.toString, service: userKeys.service.toString)
        let _ = KeychainManager.shared.delete(itemForAccount: userKeys.accessToken.toString, service: userKeys.service.toString)
        let _ = KeychainManager.shared.delete(itemForAccount: userKeys.userId.toString, service: userKeys.service.toString)
    }
    
    func getAccessToken() -> String? {
        if let token = KeychainManager.shared.getTokenToString(item: userKeys.accessToken.toString, service: userKeys.service.toString) {
            return token
        }
        
        return nil
    }

}

extension AuthService {
    func errorHandler(error: Components.Schemas.ApiError) -> String {
        var message = ""
        if let errors = error.subErrors {
            for subError in errors {
                if let errorField = subError.field, let errorMessage = subError.message {
                    message += "\(errorField.capitalized): \(errorMessage) \n"
                } else if let errorField = subError.field {
                    message += "\(errorField.capitalized): unknown error \n"
                } else if let errorMessage = subError.message {
                    message += "Unknown field: \(errorMessage) \n"
                } else {
                    message += "Unknown field: unknown error \n"
                }
            }
        } else if let msg = error.message {
            message = msg
        }
        return message.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func sanitizeMessage(_ message: String) -> String {
        let pattern = #"\(Service:.*\)"# // Match everything from "(Service:" to the closing ")"
        
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(location: 0, length: message.utf16.count)
            let sanitizedMessage = regex.stringByReplacingMatches(in: message, options: [], range: range, withTemplate: "")
            return sanitizedMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return message
    }
}

//System
extension AuthService{
    func version() async throws -> Components.Schemas.VersionInfoDto? {
        let response = try await client.versionsSupported()
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let returnResponse):
                print("\(returnResponse)")
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code from chat:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for createChatForFriends")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
}
