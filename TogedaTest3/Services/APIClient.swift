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
    
    var notificationToken = ""
    
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
        case .conflict(_):
            print("Conflict")
        }
        return nil
    }
    
    func getCurrentUserInfo() async throws -> Components.Schemas.UserInfoDto? {
        if let userId = AuthClient.shared.getUserID() {
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
        case .conflict(_):
            print("Conflict")
        }
        
        return false
    }
    
    func updateUserInfo(body: Components.Schemas.PatchUserDto) async throws  -> Bool? {
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
        case .conflict(_):
            print("Conflict")
        }
        
        return nil
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
        case .conflict(_):
            print("Conflict")
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
        }
        
        return nil
    }
    
    func getFriendList(userId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoMiniUser? {
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
        }
        
        return nil
    }
    
}

// Event
extension APIClient {
    func createEvent(body: Components.Schemas.CreatePostDto) async throws -> String? {
//        do{
            let response = try await client.createPost(body: .json(body))
            switch response {
                
            case .ok(let okResponse):
                switch okResponse.body{
                case .json(let info):
                    return info.id
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
            }
//        } catch {
//            print("Errorrrrrr: \(error.localizedDescription)")
//        }
        
        return nil
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
        }
        
        return nil
    }
    
    func getAllEvents(page: Int32, size: Int32, long: Double, lat: Double, distance: Int32, from: Date?, to: Date?, categories: [String]?) async throws -> Components.Schemas.ListResponseDtoPostResponseDto? {
//        print("Page: \(page), Seize: \(size), Cord: \(lat), \(long), Distance: \(distance), date: \(from), \(to), Category: \(categories)")
        
        let response = try await client.getAllPosts(query: .init(
            categories: categories, 
            toDate: to,
            fromDate: from,
            longitude: long,
            latitude: lat,
            distance: 3000000,
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
        case .conflict(_):
            print("Conflict")
        }
        
        return false
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
        }
        
        return nil
    }
    
    func getEventParticipantsWaitingList(postId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoMiniUser? {
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
            }
            
            return nil
    }
    
    func giveRatingToParticipant(postId: String, userId: String, ratingBody:Components.Schemas.ParticipationRatingDto) async throws -> Bool? {
            
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
            }
            
            return nil
    }
    

}

//Clubs

extension APIClient {
    func getAllClubs(page: Int32, size: Int32, long: Double, lat: Double, distance: Int32, categories: [String]?) async throws -> Components.Schemas.ListResponseDtoClubDto? {
//        print("Page: \(page), Seize: \(size), Cord: \(lat), \(long), Distance: \(distance), date: \(from), \(to), Category: \(categories)")
        
        let response = try await client.getAllClubs(query:(.init(
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
        }
        
        return nil
    }
    
    func createClub(data: Components.Schemas.CreateClubDto) async throws -> String? {
        let response = try await client.createClub(body: .json(data))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                return returnResponse.id
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
        }
        
        return nil
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
        }
        
        return nil
    }
    
    func editClub(clubID: String, body: Components.Schemas.PatchClubDto) async throws -> Bool {
        let response = try await client.patchClub(.init(path: .init(clubId: clubID), body: .json(body)))
        
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
        }
        
        return false
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
            
        }
        return nil
    }
    
    
}

//Notifications
extension APIClient {
    func addDiviceToken() async throws -> Bool?{
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
        }
        
        return nil
    }
    
    func notificationsPoll(lastTimestamp: Date, lastId: Int64, complete: @escaping ([Components.Schemas.NotificationDto]?, String?) -> Void) async throws{
        let response = try await client.pollUserNotifications(.init(query: .init(lastTimestamp: lastTimestamp, lastId: lastId)))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body{
            case .json(let returnResponse):
                complete(returnResponse, nil)
            }
        case .undocumented(statusCode: let statusCode, _):
            print("The status code:", statusCode)
            complete(nil, "The status code: \(statusCode)")
        case .unauthorized(_):
            print("Unauthorized")
            complete(nil, "Unauthorized")
        case .forbidden(_):
            print("Forbidden")
            complete(nil, "Forbidden")
        case .badRequest(_):
            print("Bad Request")
            complete(nil, "Bad Request")
        case .conflict(_):
            print("Conflict")
            complete(nil, "Conflict")
        }
        
        
    }
    
}

