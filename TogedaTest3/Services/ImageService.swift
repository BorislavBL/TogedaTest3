//
//  ImageService.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.02.24.
//

import SwiftUI

class ImageService: ObservableObject {    
    func uploadImage(imageData: Data, urlString: String) async throws{
        guard let url = URL(string: urlString) else {
            throw GeneralError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: imageData)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeneralError.noHTTPResponse
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let responseBody = String(data: data, encoding: .utf8) ?? "No error message available"
            
            if let loginErrorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw GeneralError.badRequest(details: loginErrorResponse.apierror.message)
            } else {
                print(responseBody)
                throw GeneralError.serverError(statusCode: httpResponse.statusCode, details: "Server responded with status code: \(httpResponse.statusCode)")
                
            }
        }
        
    }
    
    func generatePresignedPutUrl(bucketName: String, fileName: String) async throws -> String {
        
        guard let url = URL(string: "https://api.togeda.net/generatePresignedPutUrl?bucketName=\(bucketName)&keyName=\(fileName).jpeg") else {
            throw GeneralError.invalidURL
        }
        
        do {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeneralError.noHTTPResponse
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let responseBody = String(data: data, encoding: .utf8) ?? "No error message available"
            if let loginErrorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw GeneralError.badRequest(details: loginErrorResponse.apierror.message)
            } else {
                print(responseBody)
                throw GeneralError.serverError(statusCode: httpResponse.statusCode, details: "Server responded with status code: \(httpResponse.statusCode)")
            }
        }
        
            let decoded = try JSONDecoder().decode(PresignedPutUrl.self, from: data)
            return decoded.url
        } catch {
            throw error
        }
        
    }
    
    struct PresignedPutUrl: Codable {
        var url: String
    }
    

    func urlToUIImage(urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Error loading image: \(error)")
            return nil
        }
    }
}
