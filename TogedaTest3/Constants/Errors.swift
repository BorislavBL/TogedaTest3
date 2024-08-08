//
//  Errors.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.07.24.
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

struct APIErrorResponse1: Codable {
    let apierror: APIError
}

struct APIError: Codable {
    let status: String
    let timestamp: String
    let message: String
    let debugMessage: String?
    let subErrors: String? // Adjust types if necessary
}
