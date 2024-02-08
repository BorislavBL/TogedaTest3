//
//  PhoneNumber.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 12.12.23.
//

import Foundation

struct CPData: Codable, Identifiable {
    var id: String
    var name: String
    var flag: String
    var code: String
    var dial_code: String
    var pattern: String
    var limit: Int
    
//    static let allCountry: [CPData] = Bundle.main.decode("CountryNumbers.json")
//    static let example = allCountry[0]
}

//extension Bundle {
//    func decode<T: Decodable>(_ file: String) -> T {
//        guard let url = self.url(forResource: file, withExtension: nil) else {
//            fatalError("Failed to locate \(file) in bundle.")
//        }
//
//        guard let data = try? Data(contentsOf: url) else {
//            fatalError("Failed to load \(file) from bundle.")
//        }
//
//        let decoder = JSONDecoder()
//
//        guard let loaded = try? decoder.decode(T.self, from: data) else {
//            fatalError("Failed to decode \(file) from bundle.")
//        }
//
//        return loaded
//    }
//}
