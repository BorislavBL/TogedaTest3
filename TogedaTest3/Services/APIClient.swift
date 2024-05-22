//
//  APIClient.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 9.05.24.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes
import SwiftUI


//struct AuthenticationMiddleware: ClientMiddleware {
//    @EnvironmentObject var vm: ContentViewModel
////    let accessToken: String
//    
//    func intercept(
//        _ request: HTTPRequest,
//        body: HTTPBody?,
//        baseURL: URL,
//        operationID: String,
//        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
//    ) async throws -> (HTTPResponse, HTTPBody?) {
//        var request = request
//        AuthClient.shared.getAccessToken { token, error in
//            if let accessToken = token {
//                request.headerFields[.authorization] = "Bearer \(accessToken)"
//            } else {
//                self.vm.checkAuthStatus()
//            }
//        }
//        return try await next(request, body, baseURL)
//    }
//}

struct AuthenticationMiddleware: ClientMiddleware {
//    @EnvironmentObject var vm: ContentViewModel

    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        
        // Using a continuation to bridge the asynchronous gap
        let accessToken: String? = await withCheckedContinuation { continuation in
            AuthClient.shared.getAccessToken { token, error in
                if let accessToken = token {
                    continuation.resume(returning: accessToken)
                } else {
                    // Handle error or lack of token scenario
                    continuation.resume(returning: nil)
                }
            }
        }
        
        if let accessToken = accessToken {
            request.headerFields[.authorization] = "Bearer \(accessToken)"
        } else {
            await APIClient.shared.handleAuthenticationFailure()
        }
        
        return try await next(request, body, baseURL)
    }
}


class APIClient: ObservableObject {
    static let shared = APIClient()
    
    private var client: Client
    private let serverURL = URL(string: "https://api.togeda.net")!
    private weak var viewModel: ContentViewModel?

    private init() {
        let middlewares = [AuthenticationMiddleware()]
        client = Client(serverURL: serverURL, transport: URLSessionTransport(), middlewares: middlewares)
    }
    
    
    func setViewModel(_ viewModel: ContentViewModel) {
        self.viewModel = viewModel
    }

    @MainActor func handleAuthenticationFailure() {
        viewModel?.checkAuthStatus()
    }

}


// User
extension APIClient {
    func hasBasicInfo() async throws -> Bool?{
        let response = try await client.hasBasicInfo()
        switch response {
        case let .ok(okResponse):
            switch okResponse.body{
            case .json(let message):
                return message.hasBasicInfo
            }
                
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        }
        return nil
    }
    
    func getCurrentUserInfo() async throws -> Components.Schemas.User? {
        if let userId = AuthClient.shared.getUserID() {
            return try await getUserInfo(userId: userId)
        } else {
            print("No id")
        }
        
        return nil
    }
    
    func getUserInfo(userId: String) async throws -> Components.Schemas.User? {
        let response = try await client.getUserInfo(path: Operations.getUserInfo.Input.Path(userId: userId))
            switch response {
            case .ok(let okResponse):
                switch okResponse.body{
                case .json(let info):
                    return info
                }
            case .undocumented(statusCode: let statusCode, _):
                print("The status code:", statusCode)
            case .unauthorized(_):
                print("Unauthorized")
            case .forbidden(_):
                print("Forbidden")
            case .badRequest(_):
                print("Bad Request")
            }
        
        return nil
    }
    
    func addUserInfo(body: Components.Schemas.UserDto) async throws -> Bool {        
        let response = try await client.addBasicInfo(body: .json(body))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let info):
                 return info.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        }
        
        return false
    }
    
    func updateUserInfo(body: Components.Schemas.PatchUserDto) async throws  -> Bool {
        let response = try await client.patchUser(body:.json(body))
        switch response{
            
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let info):
                return info.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        }
        
        return false
    }
    
    
    func getUserEvents(userId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoPostResponseDto? {
        let response = try await client.getUserPosts(.init(path: .init(userId: userId), query: .init(pageable: .init(page: 0, size: 15, sort: nil))))
        
        switch response {
            
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let events):
                return events
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        }
        
        return nil
    }
    
}

// User
extension APIClient {
    func createEvent(body: Components.Schemas.CreatePostDto) async throws -> Bool {

        let response = try await client.createPost(body: .json(body))
        
        switch response {
            
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let info):
                return info.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        }
        return false
    }
    
    func getAllEvents(page: Int32, size: Int32, long: Double, lat: Double, distance: Int32, from: Date?, to: Date?) async throws -> Components.Schemas.ListResponseDtoPostResponseDto? {
        let response = try await client.getAllPosts(query: .init(
            toDate: to,
            fromDate: from,
            longitude: long,
            latitude: lat,
            distance: distance,
            pageNumber: page,
            pageSize: size
            )
        )
        switch response {
            
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let response):
                return response
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        }
        
        return nil
    }
    
    func editEvent(postId: String, editPost: Components.Schemas.PatchPostDto) async throws -> Bool {
        let response = try await client.patchPost(.init(path: .init(postId: postId), body: .json(editPost)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let response):
                return response.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        }
        
        return false
    }
    
}
