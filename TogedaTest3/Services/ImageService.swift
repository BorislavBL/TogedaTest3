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
            
            if let loginErrorResponse = try? JSONDecoder().decode(APIErrorResponse1.self, from: data) {
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
            if let loginErrorResponse = try? JSONDecoder().decode(APIErrorResponse1.self, from: data) {
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

class ImageSaver: NSObject, ObservableObject {
    @Published var hasBeenSaved: Bool = false
    func convertURLToUIImage(url: String) async throws -> UIImage? {
        guard let url = URL(string: url) else {
            return nil
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)
    }
    
    func writeToPhotoAlbum(image: UIImage?, imageURL: String?) async {
        if let uiImage = image {
            UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(saveCompleted), nil)
        } else if let url = imageURL {
            do {
                if let uiImage = try await convertURLToUIImage(url: url) {
                    UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(saveCompleted), nil)
                }
            } catch {
                print("Failed to download image: \(error.localizedDescription)")
                // Handle error (e.g., show an alert to the user)
            }
        }
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
        self.hasBeenSaved = true
    }
}
