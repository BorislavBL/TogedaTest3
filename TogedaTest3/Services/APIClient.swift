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

enum APIClientError: Error {
    case internalServerError      // 500
    case other(Error)             // anything you still want to propagate
    case badRequest(Components.Schemas.ApiError) 
}

enum AppError: Error, Sendable {
    case badRequest(Components.Schemas.ApiError)           // 400
    case unauthorized(Components.Schemas.ApiError)         // 401
    case forbidden(Components.Schemas.ApiError)            // 403
    case notFound(Components.Schemas.ApiError)             // 404
    case conflict(Components.Schemas.ApiError)             // 409
    case requestTimeout(Components.Schemas.ApiError)       // 408
    case internalServerError(Components.Schemas.ApiError?)  // 500
    case rateLimit(Components.Schemas.RateLimitError)      // 429
    case undocumented(_ status: Int,
                      _ payload: OpenAPIRuntime.UndocumentedPayload? = nil)                             // anything else
}

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
            if let accessToken = AuthService.shared.getAccessToken() {
                continuation.resume(returning: accessToken)
            } else {
                // Handle error or lack of token scenario
                continuation.resume(returning: nil)
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
    
    var notificationToken = ""
    
    private var client: Client
    private let serverURL = URL(string: TogedaMainLinks.baseURL)!
    private weak var viewModel: ContentViewModel?
    
    private init() {
        let middlewares = [AuthenticationMiddleware()]
        client = Client(serverURL: serverURL, transport: URLSessionTransport(), middlewares: middlewares)
    }
    
    func setViewModel(_ viewModel: ContentViewModel) {
        self.viewModel = viewModel
    }
    
    @MainActor func handleAuthenticationFailure() {
        Task{
            await viewModel?.validateTokens()
        }
    }
    
    func retryWithExponentialDelay<T>(
        task: @escaping () async throws -> T
    ) async throws -> T {

        var delay: TimeInterval = 10      // first retry in 10 s
        let maxDelay: TimeInterval = 20   // then every 20 s

        while true {
            do {
                return try await task()   // 👍 succeeded
            } catch let apiErr as APIClientError {
                if case .internalServerError = apiErr {
                    throw apiErr          // 👉 propagate the 500 upward
                }
                // all other APIError cases fall through to retry
            } catch {
                // some unrelated error – still retry
            }

            print("Task failed, retrying in \(delay) s…")
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            delay = maxDelay
        }
    }



}

extension APIClient {
    // 1️⃣  An error type that lists every status code you care about


}

extension APIClient {
    /// One function to handle success + every error case individually.
    /// Returns the success payload if `.ok`, otherwise `nil`.
    func processResponse<Output, Success>(
        _ response: Output,
        extractSuccess: (Output) throws -> Success
    ) throws -> Success? {
        // 1) Try success first
        if let value = try? extractSuccess(response) {
            return value
        }

        // 2) Introspect the enum case the generator returned
        let root = Mirror(reflecting: response)
        guard root.displayStyle == .enum,
              let (caseLabel, container) = root.children.first else {
            print("Unhandled response type: \(type(of: response))")
            throw AppError.undocumented(-1, nil)
            return nil
        }

        // Helper: pull `body.json(<payload>)`
        func payload() -> Any? {
            guard let body = Mirror(reflecting: container)
                    .children.first(where: { $0.label == "body" })?.value
            else { return nil }
            return Mirror(reflecting: body).children.first?.value
        }

        // Nice to have when ApiError.statusString is nil

        // 3) Per–status handling
        switch caseLabel {

        case "badRequest":
            if let api = payload() as? Components.Schemas.ApiError {
                print((api.statusString ?? "400"), api.message ?? "")
                throw AppError.badRequest(api)
                // TODO: your specific handling for 400
            }

        case "unauthorized":
            if let api = payload() as? Components.Schemas.ApiError {
                print((api.statusString ?? "401"), api.message ?? "")
                throw AppError.unauthorized(api)
                // e.g. AuthService.shared.clearSession()
            }

        case "forbidden":
            if let api = payload() as? Components.Schemas.ApiError {
                print((api.statusString ?? "403"), api.message ?? "")
                throw AppError.forbidden(api)
                // TODO: your specific handling for 403
            }

        case "notFound":
            if let api = payload() as? Components.Schemas.ApiError {
                let line = api.statusString ?? "404"
                print("\(line): \(api.message ?? "")")
                throw AppError.notFound(api)
                // TODO: your specific handling for 404
            }

        case "requestTimeout":
            if let api = payload() as? Components.Schemas.ApiError {
                print((api.statusString ?? "408"), api.message ?? "")
                throw AppError.requestTimeout(api)
                // TODO: retry, backoff, etc.
            }

        case "conflict":
            if let api = payload() as? Components.Schemas.ApiError {
                print((api.statusString ?? "409"), api.message ?? "")
                throw AppError.conflict(api)
                // TODO: conflict flow
            }

        case "tooManyRequests":
            if let rl = payload() as? Components.Schemas.RateLimitError {
                // Adjust fields to what your RateLimitError exposes
                print("429 Too Many Requests: \(rl.message)")
                throw AppError.rateLimit(rl)
                // TODO: sleep/retry after rl.retryAfter?
            }

        case "internalServerError":
            if let api = payload() as? Components.Schemas.ApiError {
                print((api.statusString ?? "500"), api.message ?? "")
                throw AppError.internalServerError(api)
                // TODO: show user-friendly "Something went wrong"
            }

        case "undocumented":
            // Pull status + UndocumentedPayload
            let assoc   = Mirror(reflecting: container).children.map(\.value)
            let status  = assoc.first as? Int ?? -1
            let pay     = assoc.dropFirst().first as? OpenAPIRuntime.UndocumentedPayload
            print("Undocumented response (\(status))")
            if (500...510).contains(status) {
                print("Internal server error2")
                DispatchQueue.main.async {
                    if let bool = self.viewModel?.internalServerError, !bool {
                        self.viewModel?.internalServerError = true
                    }
                }
                throw AppError.internalServerError(nil)
            } else {
                throw AppError.undocumented(-1, nil)
            }
            // You can inspect headers/body from `pay`
            // TODO: decide what to do

        default:
            // Anything else we didn’t expect
            print("Unhandled error case `\(caseLabel)`: \(payload() ?? "")")
        }

        return nil
    }


}
// User
extension APIClient {
//    func getUserInfoTest2() async throws -> Components.Schemas.UserInfoDto?{
//        do{
//            let response = try await client.getUserInfo(.init(path: .init(userId: "123123123123")))
//            print(try response.ok.body.json)
//            return try response.ok.body.json
//        } catch let error {
//            print(error)
//            throw error
//        }
//        return nil
//    }
    
    func getUserInfoTest() async throws -> Components.Schemas.UserInfoDto? {
        let response = try? await client.getUserInfo(
            .init(path: .init(userId: "23f4d8e2-50d1-7036-e331-a281f36"))
        )
        guard let response else { return nil }
        // The ONLY line you repeat per endpoint: how to read the success value.
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func hasBasicInfo() async throws -> Bool?{
        let response = try await client.hasBasicInfo()
        return try processResponse(response) { try $0.ok.body.json.hasBasicInfo }
    }
    
    func deleteUser() async throws -> Bool?{
        let response = try await client.deleteUser()
        return try processResponse(response) { try $0.ok.body.json.success }
        switch response {
        case let .ok(okResponse):
            switch okResponse.body{
            case .json(let message):
                return message.success
            }
            
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for hasBasicInfo")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        return nil
    }
    
    func blockUser(userId: String) async throws -> Bool?{
        let response = try await client.blockUser(.init(path: .init(userId: userId)))
        switch response {
        case let .ok(okResponse):
            switch okResponse.body{
            case .json(let message):
                return message.success
            }
            
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for hasBasicInfo")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        return nil
    }
    
    func unBlockUser(userId: String) async throws -> Bool?{
        let response = try await client.removeBlock(.init(path: .init(userId: userId)))
        switch response {
        case let .ok(okResponse):
            switch okResponse.body{
            case .json(let message):
                return message.success
            }
            
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for hasBasicInfo")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        return nil
    }
    
    func giveUserRole(userId: String, role: Operations.setUserRole.Input.Query.userRolePayload) async throws -> Bool?{
        let response = try await client.setUserRole(.init(path: .init(userId: userId), query: .init(userRole: role)))
        switch response {
        case let .ok(okResponse):
            switch okResponse.body{
            case .json(let message):
                return message.success
            }
            
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for hasBasicInfo")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        return nil
    }
    
    func changePassword(old: String, new: String, completion: @escaping (Bool?, String?) -> Void) async throws{
        let response = try await client.changePassword(.init(query: .init(prevPassword: old, newPassword: new)))
        switch response {
        case let .ok(okResponse):
            switch okResponse.body{
            case .json(let message):
                completion(message.success, nil)
            }
            
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(let error):
            switch error.body {
            case .json(let error):
                let errorMessage = errorHandler(error: error)
                completion(nil, errorMessage)
            }
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for hasBasicInfo")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(let error):
            switch error.body {
            case .json(let error):
                print(error)
                let errorMessage = errorHandler(error: error)
                completion(nil, errorMessage)
            }
        }
    }
    
    func getCurrentUserInfo() async throws -> Components.Schemas.UserInfoDto? {
        if let userId = KeychainManager.shared.getTokenToString(item: userKeys.userId.toString, service: userKeys.service.toString) {
            return try await getUserInfo(userId: userId)
        } else {
            print("No id")
        }
        
        return nil
    }
    
    func getUserInfo(userId: String) async throws -> Components.Schemas.UserInfoDto? {
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
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getUserInfo")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func searchFriends(searchText: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoMiniUser? {
        let response = try await client.searchFriends(.init(query: .init(query: searchText, pageNumber: page, pageSize: size)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
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
    
    func blockedUsers(page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoMiniUser? {
        let response = try await client.getBlockedUsers(.init(query: .init(pageNumber: page, pageSize: size)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
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
    
    func setUserActivityStatus(status: Operations.changeUserStatus.Input.Query.statusPayload) async throws -> Bool? {
        let response = try await client.changeUserStatus(.init(query: .init(status: status)))
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
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getUserInfo")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func getUserNoShows(userId: String) async throws -> Int32? {
        let response = try await client.getUserNoShows(.init(path: .init(userId: userId)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let info):
                return info.data
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getUserInfo")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func activityFeed(page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoActivityDto? {
        let response = try await client.getActivityFeed(.init(query: .init(pageNumber: page, pageSize: size)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let data):
                return data
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getUserInfo")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func addUserInfo(body: Components.Schemas.UserDto, completion: @escaping (Bool?, String?) -> Void) async throws {
        do {
            let response = try await client.addBasicInfo(body: .json(body))
            
            switch response {
            case .ok(let okResponse):
                switch okResponse.body {
                case .json(let info):
                    completion(info.success, nil)
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
                    print("Error", error)
                    let errorMessage = errorHandler(error: error)
                    completion(nil, errorMessage)
                }
                //                completion(nil, "Bad Request")
            case .conflict(_):
                completion(nil, "Conflict")
            case .tooManyRequests(_):
                completion(nil, "Too many requests for addUserInfo")
            case .requestTimeout(_):
                completion(nil, "Request timeout")
            case .notFound(_):
                completion(nil, "Not found")
            case .internalServerError(_):
                completion(nil,"Internal server error")
            }
        } catch {
            completion(nil, "Failed with error: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    func generatePresignedPutUrl(bucketName: String, keyName: String) async throws -> String? {
        let jpegName = "\(keyName).jpeg"
        let response = try await client.generatePresignedPutUrl(.init(query: .init(bucketName: bucketName, keyName: jpegName)))
        
        switch response {
            
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let response):
                return response.url
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for saveOrUnsaveEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func updateUserInfo(body: Components.Schemas.PatchUserDto, completion: @escaping (Bool?, String?) -> Void) async throws {
        do {
            let response = try await client.patchUser(body: .json(body))
            
            switch response {
            case .ok(let okResponse):
                switch okResponse.body {
                case .json(let info):
                    completion(info.success, nil)
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
                //                completion(nil, "Bad Request")
            case .conflict(_):
                completion(nil, "Conflict")
            case .tooManyRequests(_):
                completion(nil, "Too many requests for updateUserInfo")
            case .requestTimeout(_):
                completion(nil, "Request timeout")
            case .notFound(_):
                completion(nil, "Not found")
            case .internalServerError(_):
                completion(nil,"Internal server error")
            }
        } catch {
            completion(nil, "Failed with error: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    func getUserEvents(userId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoPostResponseDto? {
        let response = try await client.getUserPosts(.init(path: .init(userId: userId), query: .init(pageable: .init(page: page, size: size, sort: nil))))
        
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
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getUserEvents")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func getUserClubs(userId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoClubDto? {
        let response = try await client.getUserClubs(.init(path: .init(userId: userId), query: .init(pageNumber: page, pageSize: size)))
        
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
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getUserClubs")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func searchUsers(searchText: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoMiniUser? {
        let response = try await client.searchUsers(.init(query: .init(
            query: searchText,
            pageNumber: page,
            pageSize: size
        )))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for searchUsers")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func sendFriendRequest(sendToUserId: String) async throws -> Bool? {
        let response = try await client.sendFriendRequest(.init(path: .init(userId: sendToUserId)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for sendFriendRequest")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func respondToFriendRequest(toUserId: String, action: Operations.acceptOrDenyFriendRequest.Input.Query.actionPayload) async throws -> Bool? {
        let response = try await client.acceptOrDenyFriendRequest(.init(path: .init(userId: toUserId), query: .init(action: action)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for respondToFriendRequest")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func getFriendRequests(page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoMiniUser? {
        let response = try await client.getAllFriendRequestsForUser(.init(query: .init(pageNumber: page, pageSize: size)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getFriendRequests")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func removeFriend(removeUserId: String) async throws -> Bool? {
        let response = try await client.removeFriend(.init(path: .init(userId: removeUserId)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for removeFriend")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func removeFriendRequest(removeUserId: String) async throws -> Bool? {
        let response = try await client.cancelFriendRequest(.init(path: .init(userId: removeUserId)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for removeFriendRequest")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func getFriendList(userId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoGetFriendsDto? {
        let response = try await client.getFriends(.init(path: .init(userId: userId), query: .init(pageNumber: page, pageSize: size)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getFriendList")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func getUserSavedEvents(page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoPostResponseDto? {
        let response = try await client.getUserSavedPosts(.init(query: .init(pageNumber: page, pageSize: size)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getUserSavedEvents")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func getUserLikesList(userId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoParticipationRatingResponseDto? {
        let response = try await client.receivedRatingsForParticipatedEvents(.init(path: .init(userId: userId), query: .init(pageNumber: page, pageSize: size)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getUserLikesList")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func getUserRatingAvg(userId: String) async throws -> Components.Schemas.ReceivedEventRatingsAverageResponseDto? {
        let response = try await client.receivedEventRatingsAverage(.init(path: .init(userId: userId)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getUserRatingAvg")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func getRatingForProfile(userId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoRatingResponseDto? {
        let response = try await client.receivedEventRatings(.init(path: .init(userId: userId), query: .init(pageNumber: page, pageSize: size)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getRatingForProfile")
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

//User Badges
extension APIClient {
    func getBadges(userId: String) async throws -> [Components.Schemas.Badge]? {
        
        let response = try await client.getBadges(.init(path: .init(userId: userId)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let response):
                return response
            }
        case .undocumented(statusCode: let statusCode, let message):
            print("The status code:", statusCode, message)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func getBadgeTasks() async throws -> [Components.Schemas.BadgeTask]? {
        
        let response = try await client.getBadgeTasks()
        
        switch response {
            
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let response):
                return response
            }
        case .undocumented(statusCode: let statusCode, let message):
            print("The status code:", statusCode, message)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func getBadgeSupply() async throws -> Components.Schemas.BadgeSupplyDto? {
        
        let response = try await client.getBadgeSupply()
        
        switch response {
            
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let response):
                return response
            }
        case .undocumented(statusCode: let statusCode, let message):
            print("The status code:", statusCode, message)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getEvent")
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

extension APIClient {
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
        }
        
        if message.isEmpty, let errorMessage = error.message {
            message = errorMessage
        } else if message.isEmpty {
            message = "An unknown error occurred."
        }
        
        return message.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// Event
extension APIClient {
    func createEvent(body: Components.Schemas.CreatePostDto, completion: @escaping (String?, String?) -> Void) async throws {
        do {
            let response = try await client.createPost(body: .json(body))
            print("\(response)")
            
            switch response {
                
            case .ok(let okResponse):
                switch okResponse.body {
                case .json(let info):
                    completion(info.id, nil)
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
                //                completion(nil, "Bad Request")
            case .conflict(_):
                completion(nil, "Conflict")
            case .tooManyRequests(_):
                completion(nil, "Too many requests for createEvent")
            case .requestTimeout(_):
                completion(nil, "Request timeout")
            case .notFound(_):
                completion(nil, "Not found")
            case .internalServerError(_):
                completion(nil,"Internal server error")
            }
        } catch {
            completion(nil, "Failed with error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getEvent(postId: String) async throws -> Components.Schemas.PostResponseDto? {
        
        let response = try await client.getPostById(.init(path: .init(postId: postId)))
        
        switch response {
            
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let response):
                return response
            }
        case .undocumented(statusCode: let statusCode, let message):
            print("The status code:", statusCode, message)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func updateParticipantsArrivalStatus(postId: String, userId: String, status: Operations.updateParticipantLocationStatus.Input.Query.locationStatusPayload) async throws -> Bool? {
        
        let response = try await client.updateParticipantLocationStatus(.init(path: .init(postId: postId, userId: userId), query: .init(locationStatus: status)))
        
        switch response {
            
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let response):
                return response.success
            }
        case .undocumented(statusCode: let statusCode, let message):
            print("The status code:", statusCode, message)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func currenciesList(page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoCurrency? {
        
        let response = try await client.getPostCurrencies(.init(query: .init(pageNumber: page, pageSize: size)))
        
        switch response {
            
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let response):
                return response
            }
        case .undocumented(statusCode: let statusCode, let message):
            print("The status code:", statusCode, message)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func searchPostParticipants(postId: String, text: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoExtendedMiniUser? {
        
        let response = try await client.searchPostParticipants(.init(path: .init(postId: postId), query: .init(query: text, pageNumber: page, pageSize: size)))
        
        switch response {
            
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let response):
                return response
            }
        case .undocumented(statusCode: let statusCode, let message):
            print("The status code:", statusCode, message)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func confirmUserLocation(postId: String) async throws -> Bool? {
        
        let response = try await client.sendUserArrival(.init(path: .init(postId: postId)))
        
        switch response {
            
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let response):
                return response.success
            }
        case .undocumented(statusCode: let statusCode, let message):
            print("The status code:", statusCode, message)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func hideorRevealEvent(postId: String, isHide: Bool) async throws -> Bool? {
        let response = try await client.hideOrRevealPost(.init(path: .init(postId: postId), query: .init(isHide: isHide)))
        
        switch response {
            
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let response):
                return response.success
            }
        case .undocumented(statusCode: let statusCode, let message):
            print("The status code:", statusCode, message)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func saveOrUnsaveEvent(postId: String, isSave: Bool) async throws -> Bool? {
        
        let response = try await client.saveOrUnsavePost(.init(path: .init(postId: postId), query: .init(isSave: isSave)))
        
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
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for saveOrUnsaveEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func startOrEndEvent(postId: String, action: Operations.startOrEndPost.Input.Query.actionPayload) async throws -> Bool? {
        let response = try await client.startOrEndPost(.init(path: .init(postId: postId), query: .init(action: action)))
        
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
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for startOrEndEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func joinEvent(postId: String) async throws -> Bool? {
        let response = try await client.tryToJoinPost(.init(path: .init(postId: postId)))
        
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
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for joinEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func leaveEvent(postId: String) async throws -> Bool? {
        let response = try await client.leavePost(.init(path: .init(postId: postId)))
        
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
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for leaveEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func deleteEvent(postId: String) async throws -> Bool? {
        let response = try await client.deletePost(path: .init(postId: postId))
        
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
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for deleteEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func shareEvent(postId: String, chatRoomIds: Components.Schemas.ChatRoomIdsDto) async throws -> Bool? {
        let response = try await client.sharePost(.init(path: .init(postId: postId), body: .json(chatRoomIds)))
        
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
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for deleteEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func paidEventFees(postId: String) async throws -> Components.Schemas.PostFeeResponseDto? {
        let response = try await client.getPostFees(.init(path: .init(postId: postId)))
        
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
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for deleteEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func getAllEvents(page: Int32, size: Int32, sortBy: Operations.getAllPosts.Input.Query.sortByPayload, long: Double, lat: Double, distance: Int32, from: Date?, to: Date?, categories: [String]?) async throws -> Components.Schemas.ListResponseDtoPostResponseDto? {
        //        print("Page: \(page), Seize: \(size), Cord: \(lat), \(long), Distance: \(distance), date: \(from), \(to), Category: \(categories)")
        
        let response = try await client.getAllPosts(query: .init(
            sortBy: sortBy,
            categories: categories,
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
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getAllEvents")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func editEvent(postId: String, editPost: Components.Schemas.PatchPostDto, completion: @escaping (Bool?, String?) -> Void) async throws {
        do {
            let response = try await client.patchPost(.init(path: .init(postId: postId), body: .json(editPost)))
            
            switch response {
            case .ok(let okResponse):
                switch okResponse.body {
                case .json(let response):
                    completion(response.success, nil)
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
                //                completion(nil, "Bad Request")
            case .conflict(_):
                completion(nil, "Conflict")
            case .tooManyRequests(_):
                completion(nil, "Too many requests for editEvent")
            case .requestTimeout(_):
                completion(nil, "Request timeout")
            case .notFound(_):
                completion(nil, "Not found")
            case .internalServerError(_):
                completion(nil,"Internal server error")
            }
        } catch {
            completion(nil, "Failed with error: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    func cancelJoinRequestForEvent(postId: String) async throws -> Bool? {
        let response = try await client.cancelJoinRequestForPost(.init(path: .init(postId: postId)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for cancelJoinRequestForEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func searchEvent(searchText: String, page: Int32, size: Int32, askToJoin: Bool?) async throws -> Components.Schemas.ListResponseDtoPostResponseDto? {
        let response = try await client.searchPosts(.init(query: .init(
            query: searchText,
            askToJoin: askToJoin,
            pageNumber: page,
            pageSize: size
        )))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for searchEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func getEventParticipants(postId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoExtendedMiniUser? {
        let response = try await client.getPostParticipants(.init(path: .init(postId: postId), query: .init(pageNumber: page, pageSize: size)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getEventParticipants")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func getEventWaitlist(postId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoMiniUser? {
        let response = try await client.getWaitRequestParticipants(.init(path: .init(postId: postId), query: .init(pageNumber: page, pageSize: size)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getEventWaitlist")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func getEventParticipantsWaitingList(postId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoJoinRequestDto? {
        let response = try await client.getJoinRequestParticipants(.init(path: .init(postId: postId), query: .init(pageNumber: page, pageSize: size)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getEventParticipantsWaitingList")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func addCoHostRoleToEvent(postId: String, userId: String) async throws -> Bool {
        let response = try await client.addCoHostRole(.init(path: .init(postId: postId, userId: userId)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for addCoHostRoleToEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return false
    }
    
    func removeCoHostRoleToEvent(postId: String, userId: String) async throws -> Bool {
        let response = try await client.removeCoHostRole(.init(path: .init(postId: postId, userId: userId)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for removeCoHostRoleToEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return false
    }
    
    func removeParticipant(postId: String, userId: String) async throws -> Bool {
        let response = try await client.removeParticipant(.init(path: .init(postId: postId, userId: userId)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for removeParticipant")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return false
    }
    
    func acceptJoinRequest(postId: String, userId: String, action: Operations.acceptJoinRequest.Input.Query.actionPayload) async throws -> Bool {
        
        let response = try await client.acceptJoinRequest(.init(path: .init(postId: postId, userId: userId), query: .init(action: action)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for acceptJoinRequest")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return false
    }
    
    
    func getMapEvents(
        centerLatitude: Double,
        centerLongitude: Double,
        spanLatitudeDelta: Double,
        spanLongitudeDelta: Double, page: Int32, size: Int32 ) async throws -> Components.Schemas.ListResponseDtoPostResponseDto? {
            
            let response = try await client.findPostsInVisibleRegion(.init(query: .init(
                regionCenterLatitude: centerLatitude,
                regionCenterLongitude: centerLongitude,
                regionSpanLatitudeDelta: spanLatitudeDelta,
                regionSpanLongitudeDelta: spanLongitudeDelta,
                pageNumber: page,
                pageSize: size
            )))
            
            switch response {
            case .ok(let okResponse):
                switch okResponse.body{
                case .json(let returnResponse):
                    return returnResponse
                }
            case .undocumented(statusCode: let statusCode, _):
                print("The status code:", statusCode)
            case .unauthorized(_):
                print("Unauthorized")
            case .forbidden(_):
                print("Forbidden")
            case .badRequest(_):
                print("Bad Request")
            case .conflict(_):
                print("Conflict")
            case .tooManyRequests(_):
                print("To many Requests for getMapEvents")
            case .requestTimeout(_):
                print("Requested timeout")
            case .notFound(_):
                print("Not found")
            case .internalServerError(_):
                print("Internal server error")
            }
            
            return nil
        }
    
    func giveRatingToEvent(postId: String, ratingBody:Components.Schemas.RatingDto) async throws -> Bool? {
        
        let response = try await client.ratePost(.init(path: .init(postId: postId), body: .json(ratingBody)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for giveRatingToEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func giveRatingToParticipant(postId: String, userId: String, ratingBody: Components.Schemas.ParticipationRatingDto) async throws -> Bool? {
        
        let response = try await client.ratePostParticipant(.init(path: .init(postId: postId, userId: userId), body: .json(ratingBody)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for giveRatingToParticipant")
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

//Clubs

extension APIClient {
    func getAllClubs(page: Int32, size: Int32, sortBy: Operations.getAllClubs.Input.Query.sortByPayload, long: Double, lat: Double, distance: Int32, categories: [String]?) async throws -> Components.Schemas.ListResponseDtoClubDto? {
        //        print("Page: \(page), Seize: \(size), Cord: \(lat), \(long), Distance: \(distance), date: \(from), \(to), Category: \(categories)")
        
        let response = try await client.getAllClubs(query:(.init(
            sortBy: sortBy,
            categories: categories,
            longitude: long,
            latitude: lat,
            distance: distance,
            pageNumber: page,
            pageSize: size
        )))
        
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
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getAllClubs")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func searchClubs(searchText: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoClubDto? {
        let response = try await client.searchClubs(.init(query: .init(
            query: searchText,
            pageNumber: page,
            pageSize: size
        )))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for searchClubs")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func shareClub(clubId: String, chatRoomIds: Components.Schemas.ChatRoomIdsDto) async throws -> Bool? {
        let response = try await client.shareClub(.init(path: .init(clubId: clubId), body: .json(chatRoomIds)))
        
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
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for deleteEvent")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func createClub(data: Components.Schemas.CreateClubDto, completion: @escaping (String?, String?) -> Void) async throws {
        do {
            let response = try await client.createClub(body: .json(data))
            
            switch response {
            case .ok(let okResponse):
                switch okResponse.body {
                case .json(let returnResponse):
                    completion(returnResponse.id, nil)
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
                //                completion(nil, "Bad Request")
            case .conflict(_):
                completion(nil, "Conflict")
            case .tooManyRequests(_):
                completion(nil, "Too many requests for createClub")
            case .requestTimeout(_):
                completion(nil, "Request timeout")
            case .notFound(_):
                completion(nil, "Not found")
            case .internalServerError(_):
                completion(nil,"Internal server error")
            }
        } catch {
            completion(nil, "Failed with error: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    func getClub(clubID: String) async throws -> Components.Schemas.ClubDto? {
        let response = try await client.getClubById(.init(path: .init(clubId: clubID)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getClub")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func editClub(clubID: String, body: Components.Schemas.PatchClubDto, completion: @escaping (Bool?, String?) -> Void) async throws {
        
        let response = try await client.patchClub(.init(path: .init(clubId: clubID), body: .json(body)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
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
            //                completion(nil, "Bad Request")
        case .conflict(_):
            completion(nil, "Conflict")
        case .tooManyRequests(_):
            completion(nil, "Too many requests for editClub")
        case .requestTimeout(_):
            completion(nil, "Request timeout")
        case .notFound(_):
            completion(nil, "Not found")
        case .internalServerError(_):
            completion(nil,"Internal server error")
        }
    }
    
    
    func getClubMembers(
        clubId: String,
        page: Int32,
        size: Int32
    ) async throws -> Components.Schemas.ListResponseDtoExtendedMiniUserForClub? {
        let response = try await client.getClubMembers(
            .init(
                path: .init(clubId: clubId),
                query: .init(pageNumber: page, pageSize: size)
            )
        )
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getClubMembers")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func getClubJoinRequests(
        clubId: String,
        page: Int32,
        size: Int32
    ) async throws -> Components.Schemas.ListResponseDtoMiniUser?{
        let response = try await client.getJoinRequestParticipants_1(
            .init(
                path: .init(clubId: clubId),
                query: .init(pageNumber: page, pageSize: size)
            )
        )
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getClubJoinRequests")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func getClubEvents(
        clubId: String,
        page: Int32,
        size: Int32
    ) async throws -> Components.Schemas.ListResponseDtoPostResponseDto?{
        let response = try await client.getClubPosts(path: .init(clubId: clubId), query: .init(pageNumber: page, pageSize: size))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getClubEvents")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func getClubsWithCreatePostPermission(
        page: Int32,
        size: Int32
    ) async throws -> Components.Schemas.ListResponseDtoClubDto?{
        let response = try await client.getClubsWithCreatePostPermission(.init(query: .init(pageNumber: page, pageSize: size)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getClubsWithCreatePostPermission")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func acceptJoinRequestClub(clubId: String, userId: String, action: Operations.joinRequest.Input.Query.actionPayload) async throws -> Bool {
        
        let response = try await client.joinRequest(.init(path: .init(clubId: clubId, userId: userId), query: .init(action: action)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for acceptJoinRequestClub")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return false
    }
    
    func addAdminToClub(clubId: String, userId: String) async throws -> Bool {
        let response = try await client.addAdminRole(.init(path: .init(clubId: clubId, userId: userId)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for addAdminToClub")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return false
    }
    
    func removeClubMemeber(clubId: String, userId: String) async throws -> Bool {
        let response = try await client.removeMember(.init(path: .init(clubId: clubId, userId: userId)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for removeClubMemeber")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return false
    }
    
    func removeAdminRoleForClub(clubId: String, userId: String) async throws -> Bool {
        let response = try await client.removeAdminRole(.init(path: .init(clubId: clubId, userId: userId)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for removeAdminRoleForClub")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return false
    }
    
    func deleteClub(clubId: String) async throws -> Bool? {
        let response = try await client.delete(.init(path: .init(clubId: clubId)))
        
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
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for deleteClub")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func joinClub(clubId: String) async throws -> Bool? {
        let response = try await client.tryToJoinClub(.init(path: .init(clubId: clubId)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, let message):
            print("The status code:", statusCode, message)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func leaveClub(clubId: String) async throws -> Bool? {
        let response = try await client.leaveClub(.init(path: .init(clubId: clubId)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for leaveClub")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func cancelJoinRequestForClub(clubId: String) async throws -> Bool? {
        let response = try await client.cancelJoinRequestForClub(.init(path: .init(clubId: clubId)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for cancelJoinRequestForClub")
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

//Stripe

extension APIClient {
    func createStripeAccount() async throws -> String? {
        let response = try await client.createAccount()
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.data
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for createStripeAccount")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
            
        }
        return nil
    }
    
    func updateStripeAccount() async throws -> String? {
        let response = try await client.updateAccount()
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.data
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for createStripeAccount")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
            
        }
        return nil
    }
    
    func getStripeOnBoardingLink(accountId: String) async throws -> String? {
        let response = try await client.getOnboardingLink(.init(path: .init(accountId: accountId)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.data
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getStripeOnBoardingLink")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
            
        }
        return nil
    }
    
    func stripeOnBordingStatus(accountId: String) async throws -> Components.Schemas.StripeResponseDto? {
        let response = try await client.getOnboardingStatus(.init(path: .init(accountId: accountId)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getPaymentSheet")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
            
        }
        return nil
    }
    
    func getPaymentSheet(postId: String) async throws -> Components.Schemas.StripePaymentSheet? {
        let response = try await client.getPaymentSheet(.init(path: .init(postId: postId)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getPaymentSheet")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
            
        }
        return nil
    }
    
    func checkForPaidEvents() async throws -> Components.Schemas.StripeResponseDto? {
        let response = try await client.hasPaidPosts()
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for getPaymentSheet")
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

//Notifications
extension APIClient {
    func addDiviceToken() async throws -> Bool? {
        if !notificationToken.isEmpty {
            let response = try await client.addDeviceTokenForUser(.init(query: .init(token: notificationToken)))
            
            switch response {
            case .ok(let okResponse):
                switch okResponse.body{
                case .json(let returnResponse):
                    return returnResponse.success
                }
            case .undocumented(statusCode: let statusCode, _):
                print("The status code:", statusCode)
            case .unauthorized(_):
                print("Unauthorized")
            case .forbidden(_):
                print("Forbidden")
            case .badRequest(_):
                print("Bad Request")
            case .conflict(_):
                print("Conflict")
            case .tooManyRequests(_):
                print("To many Requests for addDiviceToken")
            case .requestTimeout(_):
                print("Requested timeout")
            case .notFound(_):
                print("Not found")
            case .internalServerError(_):
                print("Internal server error")
                
            }
        }
        return nil
    }
    
    func removeDiviceToken() async throws -> Bool?{
        if !notificationToken.isEmpty {
            let response = try await client.removeDeviceTokenForUser(.init(query: .init(token: notificationToken)))
            
            switch response {
            case .ok(let okResponse):
                switch okResponse.body{
                case .json(let returnResponse):
                    print(notificationToken)
                    return returnResponse.success
                }
            case .undocumented(statusCode: let statusCode, _):
                print("The status code:", statusCode)
            case .unauthorized(_):
                print("Unauthorized")
            case .forbidden(_):
                print("Forbidden")
            case .badRequest(_):
                print("Bad Request")
            case .conflict(_):
                print("Conflict")
            case .tooManyRequests(_):
                print("To many Requests for removeDiviceToken")
            case .requestTimeout(_):
                print("Requested timeout")
            case .notFound(_):
                print("Not found")
            case .internalServerError(_):
                print("Internal server error")
                
            }
        }
        return nil
    }
    
    func printToken() {
        print(notificationToken)
    }
    
    func notificationsList(page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoNotificationDto?{
        let response = try await client.getUserNotifications(.init(query: .init(pageNumber: page, pageSize: size)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code from notifications:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for notificationsList")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func unreadNotificationsCount() async throws -> Components.Schemas.NumberDto?{
        let response = try await client.getUnreadNotificationsCount()
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                print("Notcount", returnResponse.number)

                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code from notifications:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for notificationsList")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func readAllNotifications() async throws -> Components.Schemas.NumberDto?{
        let response = try await client.markAllNotificationsAsRead()
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code from notifications:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for notificationsList")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func updateNotifications(lastTimestamp: Date) async throws -> [Components.Schemas.NotificationDto]?{
        let response = try await client.getNotificationsAfterTimestamp(.init(query: .init(latestNotificationTimestamp: lastTimestamp)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code from notifications:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for notificationsList")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func removeRatingNotifications(postId: String) async throws -> Bool?{
        let response = try await client.removeNotificationForRatePost(.init(path: .init(postId: postId)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.success
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code from notifications:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for notificationsList")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    //    func notificationsPoll(lastTimestamp: Date, lastId: Int64, complete: @escaping ([Components.Schemas.NotificationDto]?, String?) -> Void) async throws{
    //        let response = try await client.pollUserNotifications(.init(query: .init(lastTimestamp: lastTimestamp, lastId: lastId)))
    //
    //        switch response {
    //        case .ok(let okResponse):
    //            switch okResponse.body{
    //            case .json(let returnResponse):
    //                complete(returnResponse, nil)
    //            }
    //        case .undocumented(statusCode: let statusCode, _):
    //            print("The status code:", statusCode)
    //            complete(nil, "The status code: \(statusCode)")
    //        case .unauthorized(_):
    //            print("Unauthorized")
    //            complete(nil, "Unauthorized")
    //        case .forbidden(_):
    //            print("Forbidden")
    //            complete(nil, "Forbidden")
    //        case .badRequest(_):
    //            print("Bad Request")
    //            complete(nil, "Bad Request")
    //        case .conflict(_):
    //            print("Conflict")
    //            complete(nil, "Conflict")
    //        case .tooManyRequests(_):
    //            print("To many Requests for")
    //            complete(nil, "To many Requests for notificationsPoll")
    //        case .requestTimeout(_):
    //            print("Requested timeout")
    //        case .notFound(_):
    //            print("Not found")
    //        }
    //
    //
    //    }
    
}

//Chat
extension APIClient {
    func leaveChat(chatId: String) async throws -> Bool? {
        let response = try await client.leaveChatroom(.init(path: .init(chatId: chatId)))
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
            print("Internal server error")
        }
        
        return nil
    }
    
    func leaveGroupChatRoom(chatId: String) async throws -> Bool? {
        let response = try await client.leaveGroupOrPostChatRoom(.init(path: .init(chatId: chatId)))
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
            print("Internal server error")
        }
        
        return nil
    }
    
    func unreadMessagesCount() async throws -> Components.Schemas.NumberDto?{
        let response = try await client.getUnreadMessagesCount()
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                print("Notcount", returnResponse.number)

                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code from notifications:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for notificationsList")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func enterChat(chatId: String) async throws -> Bool? {
        let response = try await client.enterChatroom(.init(path: .init(chatId: chatId)))
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
            print("Internal server error")
        }
        
        return nil
    }
    
    func addFriendToChatRoomParticipants(chatId: String, userId: String) async throws -> Bool? {
        let response = try await client.addFriendToChatRoomParticipants(.init(path: .init(chatId: chatId, userId: userId)))
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
            print("Internal server error")
        }
        
        return nil
    }
    
    func chatMessages(chatId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoReceivedChatMessageDto? {
        let response = try await client.findChatMessagesGroup(path: .init(chatId: chatId), query: .init(pageNumber: page, pageSize: size))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                
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
    
    func updateChatMessages(chatId: String, lastTimestamp: Date) async throws -> Components.Schemas.ListResponseDtoReceivedChatMessageDto? {
        let response = try await client.findChatMessagesAfterTimestamp(.init(path: .init(chatId: chatId), query: .init(latestMessageTimestamp: lastTimestamp)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code from notifications:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(_):
            print("Bad Request")
        case .conflict(_):
            print("Conflict")
        case .tooManyRequests(_):
            print("To many Requests for notificationsList")
        case .requestTimeout(_):
            print("Requested timeout")
        case .notFound(_):
            print("Not found")
        case .internalServerError(_):
            print("Internal server error")
        }
        
        return nil
    }
    
    func searchChatRoom(searchText: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoChatRoomDto? {
        let response = try await client.searchChatRooms(.init(query: .init(query: searchText, pageNumber: page, pageSize: size)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
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
    
    func likeDislikeMessage(messageId: String) async throws -> Bool? {
        let response = try await client.likeMessage(.init(path: .init(messageId: messageId)))
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
            print("Internal server error")
        }
        
        return nil
    }
    
    func editMessage(messageId: String, text: String) async throws -> Bool? {
        let response = try await client.editMessage(.init(path: .init(messageId: messageId), query: .init(content: text)))
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
            print("Internal server error")
        }
        
        return nil
    }
    
    func likeMembers(messageId: String,pageNumber: Int32, pageSize: Int32) async throws -> Components.Schemas.ListResponseDtoMiniUser? {
        let response = try await client.getMessageLikes(path: .init(messageId: messageId), query: .init(pageNumber: pageNumber, pageSize: pageSize))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
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
    
    func unsendMessage(messageId: String) async throws -> Bool? {
        let response = try await client.unsendMsg(path: .init(messageId: messageId))
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
            print("Internal server error")
        }
        
        return nil
    }
    
    func allChats(page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoChatRoomDto? {
        let response = try await client.findChatRoomsForUser(.init(query: .init(pageNumber: page, pageSize: size)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
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
    
    func allChatsRooms(page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoChatRoomDto? {
        let response = try await client.findAllChatRoomsForUser(.init(query: .init(pageNumber: page, pageSize: size)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
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
    
    func getChatParticipants(chatId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoMiniUser? {
        let response = try await client.getChatRoomParticipants(.init(path: .init(chatId: chatId), query: .init(pageNumber: page, pageSize: size)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
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
    
    func getChat(chatId: String) async throws -> Components.Schemas.ChatRoomDto? {
        let response = try await client.findChatRoomById(.init(path: .init(chatId: chatId)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
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
    
    func updateChatRooms(latestDate: Date) async throws -> [Components.Schemas.ChatRoomDto]?{
        let response = try await client.findChatRoomsWithUpdatedLatestMessageAfterTimestamp(.init(query: .init(latestMessageTimestamp: latestDate)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
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
    
    func createChatForEvent(postId: String) async throws -> String?{
        let response = try await client.createChatForPost(.init(path: .init(postId: postId)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.id
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code from chat:", statusCode)
        case .unauthorized(_):
            print("Unauthorized")
        case .forbidden(_):
            print("Forbidden")
        case .badRequest(let error):
            print("Bad Request create chat")
            switch error.body {
            case .json(let errorMessage):
                print(errorHandler(error: errorMessage))
            }
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
    
    func createChatForClub(clubId: String) async throws -> String?{
        let response = try await client.createChatForClub(.init(path: .init(clubId: clubId)))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.id
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
    
    func createGroupChat(image: String?, title: String?, friendIds: [String]) async throws -> String?{
//        let response = try await client.createChatForGroup(.init(body: .json(friendIds)))
        let response = try await client.createChatForGroup(.init(body: .json(.init(friendIds: friendIds, image: image, title: title))))
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.id
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
    
    func kickGroupParticipant(userId: String, chatId: String) async throws -> Bool?{
        let response = try await client.removeFromChatRoomParticipants(.init(path: .init(chatId: chatId, userId: userId)))
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
            print("Internal server error")
        }
        
        return nil
    }
    
    func muteChat(chatId: String) async throws -> Bool?{
        let response = try await client.muteChatroom(path: .init(chatId: chatId))
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
            print("Internal server error")
        }
        
        return nil
    }
    
    func unmuteChat(chatId: String) async throws -> Bool?{
        let response = try await client.unmuteChatroom(path: .init(chatId: chatId))
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
            print("Internal server error")
        }
        
        return nil
    }
    
    func patchGroupChat(image: String?, title: String?, chatId: String) async throws -> Bool?{
//        let response = try await client.createChatForGroup(.init(body: .json(friendIds)))
        let response = try await client.patchGroupChatRoom(.init(path: .init(chatId: chatId), body: .json(.init(title: title, image: image))))
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
            print("Internal server error")
        }
        
        return nil
    }
    
    
}

//Report

extension APIClient {
    func report(body: Components.Schemas.ReportDto) async throws -> Bool? {
        let response = try await client.sendReport(.init(body: .json(body)))
        
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
            print("Internal server error")
        }
        
        return nil
    }
}

// Admin

extension APIClient {
    func changeEventDate(postId: String, newDate: Date) async throws -> Components.Schemas.PostResponseDto? {
        let response = try await client.updatePostCreatedAt(.init(path: .init(postId: postId), query: .init(newCreatedAt: newDate)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
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
    
    func changeClubDate(clubId: String, newDate: Date) async throws -> Components.Schemas.ClubDto? {
        let response = try await client.updateClubCreatedAt(.init(path: .init(clubId: clubId), query: .init(newCreatedAt: newDate)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
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
