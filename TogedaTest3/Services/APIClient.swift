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
    private weak var bannerService: BannerService?
    
    private init() {
        let middlewares = [AuthenticationMiddleware()]
        client = Client(serverURL: serverURL, transport: URLSessionTransport(), middlewares: middlewares)
    }
    
    func setViewModel(_ viewModel: ContentViewModel) {
        self.viewModel = viewModel
    }
    
    func setBannerService(_ service: BannerService) {
        self.bannerService = service
    }
    
    @MainActor func handleAuthenticationFailure() {
        Task{
            await viewModel?.validateTokensAndCheckState()
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
    /// One function to handle success + every error case individually.
    /// Returns the success payload if `.ok`, otherwise `nil`.
    func processResponse<Output, Success>(
        _ response: Output,
        showBanners: Bool = true,
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

        func payload() -> Any? {
            guard let body = Mirror(reflecting: container)
                    .children.first(where: { $0.label == "body" })?.value
            else { return nil }
            return Mirror(reflecting: body).children.first?.value
        }

        // 3) Per–status handling
        switch caseLabel {

        case "badRequest":
            if let api = payload() as? Components.Schemas.ApiError {
                print((api.statusString ?? "400"), api.message ?? "")
                if showBanners {
                    bannerService?.setBanner(banner: .error(message: api.message ?? "Bad Request", isPersistent: false))
                }
                throw AppError.badRequest(api)
            }

        case "unauthorized":
            if let api = payload() as? Components.Schemas.ApiError {
                print((api.statusString ?? "401"), api.message ?? "")
                if showBanners {
                    bannerService?.setBanner(banner: .error(message: api.message ?? "Unauthorized", isPersistent: false))
                }
                throw AppError.unauthorized(api)
            }

        case "forbidden":
            if let api = payload() as? Components.Schemas.ApiError {
                print((api.statusString ?? "403"), api.message ?? "")
                if showBanners {
                    bannerService?.setBanner(banner: .error(message: api.message ?? "Forbidden", isPersistent: false))
                }
                throw AppError.forbidden(api)
            }

        case "notFound":
            if let api = payload() as? Components.Schemas.ApiError {
                print((api.statusString ?? "404"), api.message ?? "")
                if showBanners {
                    bannerService?.setBanner(banner: .error(message: api.message ?? "Not Found", isPersistent: false))
                }
                throw AppError.notFound(api)
            }

        case "requestTimeout":
            if let api = payload() as? Components.Schemas.ApiError {
                print((api.statusString ?? "408"), api.message ?? "")
                if showBanners {
                    bannerService?.setBanner(banner: .error(message: api.message ?? "Timeout", isPersistent: false))
                }
                throw AppError.requestTimeout(api)
            }

        case "conflict":
            if let api = payload() as? Components.Schemas.ApiError {
                print((api.statusString ?? "409"), api.message ?? "")
                if showBanners {
                    bannerService?.setBanner(banner: .error(message: api.message ?? "Conflict", isPersistent: false))
                }
                throw AppError.conflict(api)
            }

        case "tooManyRequests":
            if let rl = payload() as? Components.Schemas.RateLimitError {
                print("429 Too Many Requests: \(rl.message)")
                if showBanners {
                    bannerService?.setBanner(banner: .error(message: rl.message, isPersistent: false))
                }
                throw AppError.rateLimit(rl)
            }

        case "internalServerError":
            if let api = payload() as? Components.Schemas.ApiError {
                print((api.statusString ?? "500"), api.message ?? "")
                if showBanners {
                    bannerService?.setBanner(banner: .error(message: api.message ?? "Internal Server Error", isPersistent: false))
                }
                throw AppError.internalServerError(api)
            }

        case "undocumented":
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
                if showBanners {
                    bannerService?.setBanner(banner: .error(message: "Internal Server Error", isPersistent: false))
                }
                throw AppError.internalServerError(nil)
            } else {
                if showBanners {
                    bannerService?.setBanner(banner: .error(message: "Something went wrong", isPersistent: false))
                }
                throw AppError.undocumented(-1, nil)
            }

        default:
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
    }
    
    func blockUser(userId: String) async throws -> Bool?{
        let response = try await client.blockUser(.init(path: .init(userId: userId)))
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func unBlockUser(userId: String) async throws -> Bool?{
        let response = try await client.removeBlock(.init(path: .init(userId: userId)))
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func giveUserRole(userId: String, role: Operations.setUserRole.Input.Query.userRolePayload) async throws -> Bool?{
        let response = try await client.setUserRole(.init(path: .init(userId: userId), query: .init(userRole: role)))
        return try processResponse(response) { try $0.ok.body.json.success }
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
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func searchFriends(searchText: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoMiniUser? {
        let response = try await client.searchFriends(.init(query: .init(query: searchText, pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func blockedUsers(page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoMiniUser? {
        let response = try await client.getBlockedUsers(.init(query: .init(pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func setUserActivityStatus(status: Operations.changeUserStatus.Input.Query.statusPayload) async throws -> Bool? {
        let response = try await client.changeUserStatus(.init(query: .init(status: status)))
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func getUserNoShows(userId: String) async throws -> Int32? {
        let response = try await client.getUserNoShows(.init(path: .init(userId: userId)))
        return try processResponse(response) { try $0.ok.body.json.data }
    }
    
    func activityFeed(page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoActivityDto? {
        let response = try await client.getActivityFeed(.init(query: .init(pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json }
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
        return try processResponse(response) { try $0.ok.body.json.url }
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
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func getUserClubs(userId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoClubDto? {
        let response = try await client.getUserClubs(.init(path: .init(userId: userId), query: .init(pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func searchUsers(searchText: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoMiniUser? {
        let response = try await client.searchUsers(.init(query: .init(
            query: searchText,
            pageNumber: page,
            pageSize: size
        )))
        
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func sendFriendRequest(sendToUserId: String) async throws -> Bool? {
        let response = try await client.sendFriendRequest(.init(path: .init(userId: sendToUserId)))
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func respondToFriendRequest(toUserId: String, action: Operations.acceptOrDenyFriendRequest.Input.Query.actionPayload) async throws -> Bool? {
        let response = try await client.acceptOrDenyFriendRequest(.init(path: .init(userId: toUserId), query: .init(action: action)))
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func getFriendRequests(page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoMiniUser? {
        let response = try await client.getAllFriendRequestsForUser(.init(query: .init(pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func removeFriend(removeUserId: String) async throws -> Bool? {
        let response = try await client.removeFriend(.init(path: .init(userId: removeUserId)))
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func removeFriendRequest(removeUserId: String) async throws -> Bool? {
        let response = try await client.cancelFriendRequest(.init(path: .init(userId: removeUserId)))
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func getFriendList(userId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoGetFriendsDto? {
        let response = try await client.getFriends(.init(path: .init(userId: userId), query: .init(pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func getUserSavedEvents(page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoPostResponseDto? {
        let response = try await client.getUserSavedPosts(.init(query: .init(pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func getUserLikesList(userId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoParticipationRatingResponseDto? {
        let response = try await client.receivedRatingsForParticipatedEvents(.init(path: .init(userId: userId), query: .init(pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func getUserRatingAvg(userId: String) async throws -> Components.Schemas.ReceivedEventRatingsAverageResponseDto? {
        let response = try await client.receivedEventRatingsAverage(.init(path: .init(userId: userId)))
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func getRatingForProfile(userId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoRatingResponseDto? {
        let response = try await client.receivedEventRatings(.init(path: .init(userId: userId), query: .init(pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json }
    }
    
}

//User Badges
extension APIClient {
    func getBadges(userId: String) async throws -> [Components.Schemas.Badge]? {
        
        let response = try await client.getBadges(.init(path: .init(userId: userId)))
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func getBadgeTasks() async throws -> [Components.Schemas.BadgeTask]? {
        
        let response = try await client.getBadgeTasks()
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func getBadgeSupply() async throws -> Components.Schemas.BadgeSupplyDto? {
        
        let response = try await client.getBadgeSupply()
        return try processResponse(response) { try $0.ok.body.json }
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
    func createEvent(body: Components.Schemas.CreatePostDto) async throws -> String? {
        let response = try await client.createPost(body: .json(body))
        return try processResponse(response) { try $0.ok.body.json.id }
    }
    
    func getEvent(postId: String, showBanners: Bool = true) async throws -> Components.Schemas.PostResponseDto? {
        
        let response = try await client.getPostById(.init(path: .init(postId: postId)))
        return try processResponse(response, showBanners: showBanners) { try $0.ok.body.json }
    }
    
    func updateParticipantsArrivalStatus(postId: String, userId: String, status: Operations.updateParticipantLocationStatus.Input.Query.locationStatusPayload) async throws -> Bool? {
        
        let response = try await client.updateParticipantLocationStatus(.init(path: .init(postId: postId, userId: userId), query: .init(locationStatus: status)))
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func currenciesList(page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoCurrency? {
        
        let response = try await client.getPostCurrencies(.init(query: .init(pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func searchPostParticipants(postId: String, text: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoExtendedMiniUser? {
        
        let response = try await client.searchPostParticipants(.init(path: .init(postId: postId), query: .init(query: text, pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func confirmUserLocation(postId: String) async throws -> Bool? {
        
        let response = try await client.sendUserArrival(.init(path: .init(postId: postId)))
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func hideorRevealEvent(postId: String, isHide: Bool) async throws -> Bool? {
        let response = try await client.hideOrRevealPost(.init(path: .init(postId: postId), query: .init(isHide: isHide)))
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func saveOrUnsaveEvent(postId: String, isSave: Bool) async throws -> Bool? {
        
        let response = try await client.saveOrUnsavePost(.init(path: .init(postId: postId), query: .init(isSave: isSave)))
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func startOrEndEvent(postId: String, action: Operations.startOrEndPost.Input.Query.actionPayload) async throws -> Bool? {
        let response = try await client.startOrEndPost(.init(path: .init(postId: postId), query: .init(action: action)))
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func joinEvent(postId: String) async throws -> Bool? {
        let response = try await client.tryToJoinPost(.init(path: .init(postId: postId)))
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func leaveEvent(postId: String) async throws -> Bool? {
        let response = try await client.leavePost(.init(path: .init(postId: postId)))
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func deleteEvent(postId: String) async throws -> Bool? {
        let response = try await client.deletePost(path: .init(postId: postId))
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func shareEvent(postId: String, chatRoomIds: Components.Schemas.ChatRoomIdsDto) async throws -> Bool? {
        let response = try await client.sharePost(.init(path: .init(postId: postId), body: .json(chatRoomIds)))
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func paidEventFees(postId: String) async throws -> Components.Schemas.PostFeeResponseDto? {
        let response = try await client.getPostFees(.init(path: .init(postId: postId)))
        return try processResponse(response) { try $0.ok.body.json }
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
        return try processResponse(response) { try $0.ok.body.json }
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
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func searchEvent(searchText: String, page: Int32, size: Int32, askToJoin: Bool?) async throws -> Components.Schemas.ListResponseDtoPostResponseDto? {
        let response = try await client.searchPosts(.init(query: .init(
            query: searchText,
            askToJoin: askToJoin,
            pageNumber: page,
            pageSize: size
        )))
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func getEventParticipants(postId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoExtendedMiniUser? {
        let response = try await client.getPostParticipants(.init(path: .init(postId: postId), query: .init(pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func getEventWaitlist(postId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoMiniUser? {
        let response = try await client.getWaitRequestParticipants(.init(path: .init(postId: postId), query: .init(pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func getEventParticipantsWaitingList(postId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoJoinRequestDto? {
        let response = try await client.getJoinRequestParticipants(.init(path: .init(postId: postId), query: .init(pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func addCoHostRoleToEvent(postId: String, userId: String) async throws -> Bool {
        let response = try await client.addCoHostRole(.init(path: .init(postId: postId, userId: userId)))
        return try processResponse(response) { try $0.ok.body.json.success } ?? false
    }
    
    func removeCoHostRoleToEvent(postId: String, userId: String) async throws -> Bool {
        let response = try await client.removeCoHostRole(.init(path: .init(postId: postId, userId: userId)))
        return try processResponse(response) { try $0.ok.body.json.success } ?? false
    }
    
    func removeParticipant(postId: String, userId: String) async throws -> Bool {
        let response = try await client.removeParticipant(.init(path: .init(postId: postId, userId: userId)))
        return try processResponse(response) { try $0.ok.body.json.success } ?? false
    }
    
    func acceptJoinRequest(postId: String, userId: String, action: Operations.acceptJoinRequest.Input.Query.actionPayload) async throws -> Bool {
        
        let response = try await client.acceptJoinRequest(.init(path: .init(postId: postId, userId: userId), query: .init(action: action)))
        return try processResponse(response) { try $0.ok.body.json.success } ?? false
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
            
            return try processResponse(response) { try $0.ok.body.json }
        }
    
    func giveRatingToEvent(postId: String, ratingBody:Components.Schemas.RatingDto) async throws -> Bool? {
        
        let response = try await client.ratePost(.init(path: .init(postId: postId), body: .json(ratingBody)))
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func giveRatingToParticipant(postId: String, userId: String, ratingBody: Components.Schemas.ParticipationRatingDto) async throws -> Bool? {
        
        let response = try await client.ratePostParticipant(.init(path: .init(postId: postId, userId: userId), body: .json(ratingBody)))
        return try processResponse(response) { try $0.ok.body.json.success }
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
        
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func searchClubs(searchText: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoClubDto? {
        let response = try await client.searchClubs(.init(query: .init(
            query: searchText,
            pageNumber: page,
            pageSize: size
        )))
        
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func shareClub(clubId: String, chatRoomIds: Components.Schemas.ChatRoomIdsDto) async throws -> Bool? {
        let response = try await client.shareClub(.init(path: .init(clubId: clubId), body: .json(chatRoomIds)))
        
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func createClub(data: Components.Schemas.CreateClubDto) async throws -> String? {
        let response = try await client.createClub(body: .json(data))
        return try processResponse(response) { try $0.ok.body.json.id }
    }
    
    
    func getClub(clubID: String, showBanners: Bool = true) async throws -> Components.Schemas.ClubDto? {
        let response = try await client.getClubById(.init(path: .init(clubId: clubID)))
        return try processResponse(response, showBanners: showBanners) { try $0.ok.body.json }
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
        
        return try processResponse(response) { try $0.ok.body.json }
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
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func getClubEvents(
        clubId: String,
        page: Int32,
        size: Int32
    ) async throws -> Components.Schemas.ListResponseDtoPostResponseDto?{
        let response = try await client.getClubPosts(path: .init(clubId: clubId), query: .init(pageNumber: page, pageSize: size))
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func getClubsWithCreatePostPermission(
        page: Int32,
        size: Int32
    ) async throws -> Components.Schemas.ListResponseDtoClubDto?{
        let response = try await client.getClubsWithCreatePostPermission(.init(query: .init(pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json }
    }
    
    func acceptJoinRequestClub(clubId: String, userId: String, action: Operations.joinRequest.Input.Query.actionPayload) async throws -> Bool {
        
        let response = try await client.joinRequest(.init(path: .init(clubId: clubId, userId: userId), query: .init(action: action)))
        return try processResponse(response) { try $0.ok.body.json.success} ?? false
    }
    
    func addAdminToClub(clubId: String, userId: String) async throws -> Bool {
        let response = try await client.addAdminRole(.init(path: .init(clubId: clubId, userId: userId)))
        return try processResponse(response) { try $0.ok.body.json.success} ?? false
    }
    
    func removeClubMemeber(clubId: String, userId: String) async throws -> Bool {
        let response = try await client.removeMember(.init(path: .init(clubId: clubId, userId: userId)))
        return try processResponse(response) { try $0.ok.body.json.success} ?? false
    }
    
    func removeAdminRoleForClub(clubId: String, userId: String) async throws -> Bool {
        let response = try await client.removeAdminRole(.init(path: .init(clubId: clubId, userId: userId)))
        return try processResponse(response) { try $0.ok.body.json.success} ?? false
    }
    
    func deleteClub(clubId: String) async throws -> Bool? {
        let response = try await client.delete(.init(path: .init(clubId: clubId)))
        return try processResponse(response) { try $0.ok.body.json.success}
    }
    
    func joinClub(clubId: String) async throws -> Bool? {
        let response = try await client.tryToJoinClub(.init(path: .init(clubId: clubId)))
        return try processResponse(response) { try $0.ok.body.json.success}
    }
    
    func leaveClub(clubId: String) async throws -> Bool? {
        let response = try await client.leaveClub(.init(path: .init(clubId: clubId)))
        return try processResponse(response) { try $0.ok.body.json.success}
    }
    
    func cancelJoinRequestForClub(clubId: String) async throws -> Bool? {
        let response = try await client.cancelJoinRequestForClub(.init(path: .init(clubId: clubId)))
        return try processResponse(response) { try $0.ok.body.json.success}
    }
}

//Stripe

extension APIClient {
    func createStripeAccount() async throws -> String? {
        let response = try await client.createAccount()
        return try processResponse(response) { try $0.ok.body.json.data}
    }
    
    func deleteStripeAccount() async throws -> String? {
        let response = try await client.deleteAccount()
        return try processResponse(response) { try $0.ok.body.json.data}
    }
    
    func updateStripeAccount() async throws -> String? {
        let response = try await client.updateAccount()
        return try processResponse(response) { try $0.ok.body.json.data}
    }
    
    func getStripeAccountInfo() async throws -> Components.Schemas.StripeAccountDto? {
        let response = try await client.getStripeAccountInfo()
        return try processResponse(response, showBanners: false) { try $0.ok.body.json}
    }
    
    func getStripeOnBoardingLink(accountId: String) async throws -> String? {
        let response = try await client.getOnboardingLink(.init(path: .init(accountId: accountId)))
        return try processResponse(response) { try $0.ok.body.json.data}
    }
    
    func stripeOnBordingStatus(accountId: String) async throws -> Components.Schemas.StripeResponseDto? {
        let response = try await client.getOnboardingStatus(.init(path: .init(accountId: accountId)))
        return try processResponse(response) { try $0.ok.body.json}
    }
    
    func getPaymentSheet(postId: String) async throws -> Components.Schemas.StripePaymentSheet? {
        let response = try await client.getPaymentSheet(.init(path: .init(postId: postId)))
        return try processResponse(response) { try $0.ok.body.json}
    }
    
    func checkForPaidEvents() async throws -> Components.Schemas.StripeResponseDto? {
        let response = try await client.hasPaidPosts()
        return try processResponse(response) { try $0.ok.body.json}
    }
    
}

//Notifications
extension APIClient {
    func addDiviceToken() async throws -> Bool? {
        if !notificationToken.isEmpty {
            let response = try await client.addDeviceTokenForUser(.init(query: .init(token: notificationToken)))
            return try processResponse(response) { try $0.ok.body.json.success}
        }
        return nil
    }
    
    func removeDiviceToken() async throws -> Bool?{
        if !notificationToken.isEmpty {
            let response = try await client.removeDeviceTokenForUser(.init(query: .init(token: notificationToken)))
            return try processResponse(response) { try $0.ok.body.json.success}
        }
        return nil
    }
    
    func printToken() {
        print(notificationToken)
    }
    
    func notificationsList(page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoNotificationDto?{
        let response = try await client.getUserNotifications(.init(query: .init(pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json}
    }
    
    func unreadNotificationsCount() async throws -> Components.Schemas.NumberDto?{
        let response = try await client.getUnreadNotificationsCount()
        return try processResponse(response) { try $0.ok.body.json}
    }
    
    func readAllNotifications() async throws -> Components.Schemas.NumberDto?{
        let response = try await client.markAllNotificationsAsRead()
        return try processResponse(response) { try $0.ok.body.json}
    }
    
    func updateNotifications(lastTimestamp: Date) async throws -> [Components.Schemas.NotificationDto]?{
        let response = try await client.getNotificationsAfterTimestamp(.init(query: .init(latestNotificationTimestamp: lastTimestamp)))
        return try processResponse(response) { try $0.ok.body.json}
    }
    
    func removeRatingNotifications(postId: String) async throws -> Bool?{
        let response = try await client.removeNotificationForRatePost(.init(path: .init(postId: postId)))
        return try processResponse(response) { try $0.ok.body.json.success}
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
        return try processResponse(response) { try $0.ok.body.json.success}
    }
    
    func leaveGroupChatRoom(chatId: String) async throws -> Bool? {
        let response = try await client.leaveGroupOrPostChatRoom(.init(path: .init(chatId: chatId)))
        return try processResponse(response) { try $0.ok.body.json.success}
    }
    
    func unreadMessagesCount() async throws -> Components.Schemas.NumberDto?{
        let response = try await client.getUnreadMessagesCount()
        return try processResponse(response) { try $0.ok.body.json}
    }
    
    func enterChat(chatId: String) async throws -> Bool? {
        let response = try await client.enterChatroom(.init(path: .init(chatId: chatId)))
        return try processResponse(response) { try $0.ok.body.json.success}
    }
    
    func addFriendToChatRoomParticipants(chatId: String, userId: String) async throws -> Bool? {
        let response = try await client.addFriendToChatRoomParticipants(.init(path: .init(chatId: chatId, userId: userId)))
        return try processResponse(response) { try $0.ok.body.json.success}
    }
    
    func chatMessages(chatId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoReceivedChatMessageDto? {
        let response = try await client.findChatMessagesGroup(path: .init(chatId: chatId), query: .init(pageNumber: page, pageSize: size))
        return try processResponse(response) { try $0.ok.body.json}
    }
    
    func updateChatMessages(chatId: String, lastTimestamp: Date) async throws -> Components.Schemas.ListResponseDtoReceivedChatMessageDto? {
        let response = try await client.findChatMessagesAfterTimestamp(.init(path: .init(chatId: chatId), query: .init(latestMessageTimestamp: lastTimestamp)))
        return try processResponse(response) { try $0.ok.body.json}
    }
    
    func searchChatRoom(searchText: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoChatRoomDto? {
        let response = try await client.searchChatRooms(.init(query: .init(query: searchText, pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json}
    }
    
    func likeDislikeMessage(messageId: String) async throws -> Bool? {
        let response = try await client.likeMessage(.init(path: .init(messageId: messageId)))
        return try processResponse(response) { try $0.ok.body.json.success }

    }
    
    func editMessage(messageId: String, text: String) async throws -> Bool? {
        let response = try await client.editMessage(.init(path: .init(messageId: messageId), query: .init(content: text)))
        return try processResponse(response) { try $0.ok.body.json.success }
    }
    
    func likeMembers(messageId: String,pageNumber: Int32, pageSize: Int32) async throws -> Components.Schemas.ListResponseDtoMiniUser? {
        let response = try await client.getMessageLikes(path: .init(messageId: messageId), query: .init(pageNumber: pageNumber, pageSize: pageSize))
        return try processResponse(response) { try $0.ok.body.json }


    }
    
    func unsendMessage(messageId: String) async throws -> Bool? {
        let response = try await client.unsendMsg(path: .init(messageId: messageId))
        return try processResponse(response) { try $0.ok.body.json.success }

    }
    
    func allChats(page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoChatRoomDto? {
        let response = try await client.findChatRoomsForUser(.init(query: .init(pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json }

    }
    
    func allChatsRooms(page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoChatRoomDto? {
        let response = try await client.findAllChatRoomsForUser(.init(query: .init(pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json }

    }
    
    func getChatParticipants(chatId: String, page: Int32, size: Int32) async throws -> Components.Schemas.ListResponseDtoMiniUser? {
        let response = try await client.getChatRoomParticipants(.init(path: .init(chatId: chatId), query: .init(pageNumber: page, pageSize: size)))
        return try processResponse(response) { try $0.ok.body.json }

    }
    
    func getChat(chatId: String) async throws -> Components.Schemas.ChatRoomDto? {
        let response = try await client.findChatRoomById(.init(path: .init(chatId: chatId)))
        return try processResponse(response) { try $0.ok.body.json }

    }
    
    func updateChatRooms(latestDate: Date) async throws -> [Components.Schemas.ChatRoomDto]?{
        let response = try await client.findChatRoomsWithUpdatedLatestMessageAfterTimestamp(.init(query: .init(latestMessageTimestamp: latestDate)))
        return try processResponse(response) { try $0.ok.body.json }

    }
    
    func createChatForEvent(postId: String) async throws -> String?{
        let response = try await client.createChatForPost(.init(path: .init(postId: postId)))
        return try processResponse(response) { try $0.ok.body.json.id }

    }
    
    func createChatForClub(clubId: String) async throws -> String?{
        let response = try await client.createChatForClub(.init(path: .init(clubId: clubId)))
        return try processResponse(response) { try $0.ok.body.json.id }

    }
    
    func createGroupChat(image: String?, title: String?, friendIds: [String]) async throws -> String?{
//        let response = try await client.createChatForGroup(.init(body: .json(friendIds)))
        let response = try await client.createChatForGroup(.init(body: .json(.init(friendIds: friendIds, image: image, title: title))))
        return try processResponse(response) { try $0.ok.body.json.id }

    }
    
    func kickGroupParticipant(userId: String, chatId: String) async throws -> Bool?{
        let response = try await client.removeFromChatRoomParticipants(.init(path: .init(chatId: chatId, userId: userId)))
        return try processResponse(response) { try $0.ok.body.json.success }

    }
    
    func muteChat(chatId: String) async throws -> Bool?{
        let response = try await client.muteChatroom(path: .init(chatId: chatId))
        return try processResponse(response) { try $0.ok.body.json.success }

    }
    
    func unmuteChat(chatId: String) async throws -> Bool?{
        let response = try await client.unmuteChatroom(path: .init(chatId: chatId))
        return try processResponse(response) { try $0.ok.body.json.success }

    }
    
    func patchGroupChat(image: String?, title: String?, chatId: String) async throws -> Bool?{
//        let response = try await client.createChatForGroup(.init(body: .json(friendIds)))
        let response = try await client.patchGroupChatRoom(.init(path: .init(chatId: chatId), body: .json(.init(title: title, image: image))))
        return try processResponse(response) { try $0.ok.body.json.success }

    }
    
    
}

//Report

extension APIClient {
    func report(body: Components.Schemas.ReportDto) async throws -> Bool? {
        let response = try await client.sendReport(.init(body: .json(body)))
        return try processResponse(response) { try $0.ok.body.json.success }

    }
}

// Admin

extension APIClient {
    func changeEventDate(postId: String, newDate: Date) async throws -> Components.Schemas.PostResponseDto? {
        let response = try await client.updatePostCreatedAt(.init(path: .init(postId: postId), query: .init(newCreatedAt: newDate)))
        
        return try processResponse(response) { try $0.ok.body.json }

    }
    
    func changeClubDate(clubId: String, newDate: Date) async throws -> Components.Schemas.ClubDto? {
        let response = try await client.updateClubCreatedAt(.init(path: .init(clubId: clubId), query: .init(newCreatedAt: newDate)))
        return try processResponse(response) { try $0.ok.body.json }

    }
}
