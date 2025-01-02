//
//  DecodedJWT.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 12.02.24.
//

import Foundation

struct DecodedJWTBody: Codable {
    let authTime: Int
    let originJti: String?
    let scope: String?
    let jti: String?
    let iss: String?
    let sub: String?
    let clientId: String?
    let tokenUse: String?
    let username: String?
    let exp: Int
    let iat: Int?
    let eventId: String?
    
    enum CodingKeys: String, CodingKey {
        case authTime = "auth_time"
        case originJti = "origin_jti"
        case scope
        case jti
        case iss
        case sub
        case clientId = "client_id"
        case tokenUse = "token_use"
        case username
        case exp
        case iat
        case eventId = "event_id"
    }
}
