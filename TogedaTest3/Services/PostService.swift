//
//  PostService.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import Foundation

class PostService {
    func createPost(userData: CreatePost) async throws {
        guard let encoded = try? JSONEncoder().encode(userData) else {
            throw GeneralError.encodingError
        }
        
        guard let url = URL(string: "https://api.togeda.net/posts") else {
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
            let decodedUsers = try JSONDecoder().decode(createPostResponse.self, from: data)
            print(decodedUsers)
        } catch {
            throw GeneralError.decodingError
        }
        
    }
    
    struct createPostResponse: Codable {
        let success: Bool
    }
    
    func fetchPosts(withIDs ids: [String]) -> [Post] {
        return Post.MOCK_POSTS.filter { post in
            return ids.contains(post.id)
        }
    }
}
