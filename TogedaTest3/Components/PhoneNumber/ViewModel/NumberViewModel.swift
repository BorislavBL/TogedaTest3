//
//  NumberViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 27.02.24.
//

import Foundation

class NumberViewModel: ObservableObject {
    func loadJsonData() -> [CPData] {
        guard let url = Bundle.main.url(forResource: "CountryNumbers", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Json file not found")
            return []
        }
        do {
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode([CPData].self, from: data)
            return jsonData
        } catch {
            print("Error decoding JSON: \(error)")
            return []
        }
    }
}
