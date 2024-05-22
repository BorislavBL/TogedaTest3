//
//  JWTDecoder.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 9.05.24.
//

import Foundation
import JWTDecode

func getDecodedJWTBody(token: String) -> DecodedJWTBody? {
    do {
        // Assuming `decode(jwt:)` function is capable of returning the decoded JWT body as a Dictionary
        let jwtBody = try decode(jwt: token)
        // Convert the dictionary to JSON data
        let jsonData = try JSONSerialization.data(withJSONObject: jwtBody.body, options: [])
        // Decode the JSON data to `DecodedJWTBody` struct
        let decodedJWTBody = try JSONDecoder().decode(DecodedJWTBody.self, from: jsonData)
        return decodedJWTBody
    } catch {
        print("Error decoding JWT: \(error)")
        return nil
    }
}
