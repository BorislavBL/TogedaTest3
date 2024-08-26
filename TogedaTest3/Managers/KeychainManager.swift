//
//  KeychainHelper.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 7.02.24.
//

import Foundation
import Security

enum userKeys {
    case accessToken
    case refreshToken
    case userId
    case service
    
    var toString: String {
        switch self {
        case .accessToken:
            return "userAccessToken"
        case .refreshToken:
            return "userRefreshToken"
        case .userId:
            return "userId"
        case .service:
            return "net-togeda-app"
        }
    }
}

class KeychainManager {
    
    static let shared = KeychainManager()
    
    enum KeychainError: Error {
        case duplicatesEntry
        case unknown(OSStatus)
    }
    
    func saveOrUpdate(item: String, account: String, service: String) -> Bool {
        let item = Data(item.utf8)
        // Check if the item already exists
        if retrieve(itemForAccount: account, service: service) != nil {
            // Update existing item
            return update(item: item, account: account, service: service)
        } else {
            // Add new item
            return add(item: item, account: account, service: service)
        }
    }
    
    // Retrieve an item from the Keychain
    func retrieve(itemForAccount account: String, service: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess, let data = item as? Data {
            return data
        } else {
            return nil
        }
    }
    
    // Delete an item from the Keychain
    func delete(itemForAccount account: String, service: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        return status == errSecSuccess
    }
    
    private func add(item: Data, account: String, service: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecValueData as String: item
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        return status == errSecSuccess
    }
    
    private func update(item: Data, account: String, service: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        let updateFields: [String: Any] = [kSecValueData as String: item]
        
        let status = SecItemUpdate(query as CFDictionary, updateFields as CFDictionary)
        
        return status == errSecSuccess
    }
}

extension KeychainManager {
    func getTokenToString(item: String, service: String) -> String? {
        if let tokenData = self.retrieve(itemForAccount: item, service: service),
           let tokenString = String(data: tokenData, encoding: .utf8) {
            return tokenString
        } else {
            print("Failed to retrieve tokens")
            return nil
        }
    }
    
    func getToken(item: String, service: String) -> DecodedJWTBody? {
        if let tokenData = self.retrieve(itemForAccount: item, service: service),
           let tokenString = String(data: tokenData, encoding: .utf8) {
            let token = getDecodedJWTBody(token: tokenString)
            return token
        } else {
            print("Failed to retrieve tokens")
            return nil
        }
    }
    
}


//    static func save(data: Data, forService service: String, account: String) throws {
//        let query: [String: AnyObject] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrService as String: service as AnyObject,
//            kSecAttrAccount as String: account as AnyObject,
//            kSecValueData as String: data as AnyObject
//        ]
//
//        let status = SecItemAdd(query as CFDictionary, nil)
//        guard status != errSecDuplicateItem else {
//            throw KeychainError.duplicatesEntry
//        }
//
//        guard status == errSecSuccess else {
//            throw KeychainError.unknown(status)
//        }
//    }
//
//    static func get(forService service: String, account: String) throws -> Data? {
//        let query: [String: AnyObject] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrService as String: service as AnyObject,
//            kSecAttrAccount as String: account as AnyObject,
//            kSecReturnRef as String: kCFBooleanTrue,
//            kSecMatchLimit as String: kSecMatchLimitOne
//        ]
//
//        var result: AnyObject?
//        let status = SecItemCopyMatching(query as CFDictionary, &result)
//        return result as? Data
//    }
